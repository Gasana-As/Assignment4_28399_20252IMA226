# Implementation and Performance Notes

## Design
- **Business rules live in the database.** Procedures validate input, call small
  functions (`get_letter_grade`, `get_seats_left`, ...) and raise meaningful
  `ORA-20xxx` errors. Constraints (PK, FK, UNIQUE, CHECK) are the last line of defence.
- **Errors are never swallowed.** Every `WHEN OTHERS` handler logs to `ERROR_LOG`
  (autonomous transaction, so the log survives a rollback) and then re-raises with `RAISE`.
  Functions do not log (they are callable from SQL, where DML is not allowed) and do not
  catch unexpected errors, so callers never receive a misleading value.
  `calc_student_gpa` returns `NULL` – not 0 – when a student has no graded courses.
- **Transaction control belongs to the caller.** Procedures do not `COMMIT`
  (except `log_error`), so a caller can group several calls and roll back together.

## Records and collections
- User-defined record `t_transcript_rec` holds one transcript line fetched by an explicit cursor.
- `%ROWTYPE` holds whole `STUDENTS`/`COURSES` rows; `get_student_record` returns one.
- Associative arrays hold batches of IDs/scores for `FORALL`; one is indexed by `VARCHAR2`
  (grade counts). A nested table (`t_number_tab`) is the public parameter/return type
  because it can be created from SQL and used with `TABLE()`. A VARRAY holds the fixed
  list of grade labels.

## Cursors
- Implicit cursor attributes (`SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND`) are read
  immediately after the DML and copied to a variable, because the next SQL statement
  overwrites them.
- Explicit cursors: OPEN/FETCH/CLOSE with `%NOTFOUND` and `%ISOPEN` cleanup in the handler;
  cursor FOR loop for read-only reporting.

## Bulk processing and performance
Row-by-row processing switches between the PL/SQL and SQL engines once per row.
`BULK COLLECT` fetches many rows in a single switch and `FORALL` sends a whole
collection of DML in a single switch, which removes most of that overhead
(`compare_bulk_vs_loop` measures it – paste your timings below).

- `BULK COLLECT ... LIMIT 100` in `bulk_apply_curve` keeps session memory (PGA) bounded
  on large courses; an unbounded `BULK COLLECT` could exhaust memory on millions of rows.
- `FORALL ... SAVE EXCEPTIONS` lets valid rows succeed while failures (ORA-24381) are
  read from `SQL%BULK_EXCEPTIONS`, reported and logged. Without it, the first error stops the batch.
- `FORALL` is not a loop: it can contain only one DML statement, which is why the update
  and the audit insert are two `FORALL` statements.
- Capacity is checked *before* the bulk insert, since a single set-based insert cannot
  re-check seats per row.

### Measured results (fill in from your run)
| Rows | Row-by-row (cs) | FORALL (cs) |
|------|-----------------|-------------|
| 20,000 | <fill> | <fill> |
