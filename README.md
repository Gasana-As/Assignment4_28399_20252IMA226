# Group Assignment IV – Student Registration and Grading System (Oracle PL/SQL)

**Course:** Database Development with PL/SQL (INSY 8311) – Instructor: Eric Maniraguha
**Class group:** <I / B / C / D>

## Group members
| Full name | Student ID |
|-----------|------------|
| <Member 1 full name> | <ID1> |
| <Member 2 full name> | <ID2> |

## Application description
A university registration and grading back-end. Students enroll in courses for a
semester, lecturers record scores, and the system computes letter grades, GPA,
transcripts and course reports.

**Requirements covered**
- Enroll / drop students with capacity, status and duplicate checks.
- Record and audit scores (letter grade derived from score).
- Bulk operations: enroll a list of students, apply a curve to a whole course, recalculate every GPA.
- Reports: student transcript and course roster with grade distribution.
- Central error logging (`ERROR_LOG`, autonomous transaction).

**Tables:** `STUDENTS`, `COURSES`, `ENROLLMENTS` (FKs to both, unique per student/course/semester),
`GRADE_AUDIT`, `ERROR_LOG`, `PERF_TEST` (performance demo only). Type: `T_NUMBER_TAB` (nested table).

## Where each required concept is used
| Concept | Where |
|---|---|
| User-defined record | `print_transcript` (`t_transcript_rec`) |
| `%ROWTYPE` | `enroll_student`, `print_transcript`, `course_report`, `get_student_record` (returned by a function) |
| Associative array | `bulk_apply_curve`, `recalculate_all_gpa`, `course_report` (indexed by VARCHAR2) |
| Nested table | `t_number_tab` in `bulk_enroll_students`, `get_top_students` |
| VARRAY | `course_report` (grade labels) |
| Implicit cursor (`SQL%ROWCOUNT/FOUND/NOTFOUND`) | `enroll_student`, `update_score`, `drop_enrollment` |
| Explicit cursor | OPEN/FETCH/CLOSE: `print_transcript`, `bulk_apply_curve`; cursor FOR loop: `course_report` |
| `BULK COLLECT` | `bulk_apply_curve` (with `LIMIT`), `recalculate_all_gpa`, `get_top_students` |
| `FORALL` + `SAVE EXCEPTIONS` | `bulk_enroll_students`, `recalculate_all_gpa`, `bulk_apply_curve`, `compare_bulk_vs_loop` |
| Predefined exceptions | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX` |
| User-defined exceptions | `e_student_inactive`, `e_course_full`, `e_already_graded`, `e_bulk_errors` |
| `RAISE_APPLICATION_ERROR` | all procedures/functions (codes below) |

## Error codes
| Code | Meaning |
|---|---|
| -20001..-20004 | enroll: student missing / inactive / course full / duplicate |
| -20011, -20012 | update_score: not enrolled / no row updated |
| -20020, -20021 | drop_enrollment: not found / already graded |
| -20030, -20032 | bulk enroll: empty list / not enough seats |
| -20040, -20042 | curve: invalid bonus / GPA recalculation bulk errors |
| -20050 | invalid score |
| -20060 | GPA: student missing |
| -20070 | course missing |
| -20080 | invalid N |
| -20090..-20092 | student record / name lookup (missing, ambiguous) |
| -20110 | course_report: course missing |
| -20120 | invalid row count in perf demo |

## How to run (Oracle 12c or later)
1. Run `00_schema/01_create_tables.sql`
2. Run `00_schema/02_insert_sample_data.sql`
3. Compile the procedures in `01_procedures/` (start with `log_error.sql`)
4. Compile the functions in `02_functions/`
5. Recompile anything left invalid (procedures reference functions): `EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER, FALSE);`
   and check `SELECT object_name, status FROM user_objects WHERE status <> 'VALID';`
6. Run `03_tests/test_success_cases.sql` then `03_tests/test_error_cases.sql` (use `SET SERVEROUTPUT ON`)
7. Screenshots of every test output are in `screenshots/`

See `docs/IMPLEMENTATION_NOTES.md` for design and performance notes.

## AI usage disclosure
<EDIT THIS to match what you actually did.> An AI assistant (Claude) was used to
generate a first draft of the schema, PL/SQL code, tests and documentation. Both
members reviewed, ran, tested and modified the code, and both can explain every
part of it.
