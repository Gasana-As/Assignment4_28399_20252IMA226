-- Performance demo: inserts N rows row-by-row, then with FORALL, and prints
-- the elapsed time of each (centiseconds, via DBMS_UTILITY.GET_TIME).
-- Cleans up with DELETE (no commit/rollback; the caller controls the transaction).
CREATE OR REPLACE PROCEDURE compare_bulk_vs_loop (
    p_rows IN PLS_INTEGER DEFAULT 20000
) IS
    TYPE t_id_tab  IS TABLE OF perf_test.id%TYPE      INDEX BY PLS_INTEGER;
    TYPE t_pay_tab IS TABLE OF perf_test.payload%TYPE INDEX BY PLS_INTEGER;
    v_ids   t_id_tab;
    v_pay   t_pay_tab;
    v_start PLS_INTEGER;
    v_loop  PLS_INTEGER;
    v_bulk  PLS_INTEGER;
BEGIN
    IF p_rows IS NULL OR p_rows NOT BETWEEN 1 AND 1000000 THEN
        RAISE_APPLICATION_ERROR(-20120, 'p_rows must be between 1 and 1,000,000.');
    END IF;

    DELETE FROM perf_test;

    -- 1) Row-by-row: one PL/SQL -> SQL context switch per row
    v_start := DBMS_UTILITY.GET_TIME;
    FOR i IN 1 .. p_rows LOOP
        INSERT INTO perf_test (id, payload) VALUES (i, 'row ' || i);
    END LOOP;
    v_loop := DBMS_UTILITY.GET_TIME - v_start;

    DELETE FROM perf_test;

    -- 2) Bulk: one context switch for the whole collection
    FOR i IN 1 .. p_rows LOOP
        v_ids(i) := i;
        v_pay(i) := 'row ' || i;
    END LOOP;

    v_start := DBMS_UTILITY.GET_TIME;
    FORALL i IN 1 .. p_rows
        INSERT INTO perf_test (id, payload) VALUES (v_ids(i), v_pay(i));
    v_bulk := DBMS_UTILITY.GET_TIME - v_start;

    DELETE FROM perf_test;

    DBMS_OUTPUT.PUT_LINE('Rows: ' || p_rows);
    DBMS_OUTPUT.PUT_LINE('Row-by-row loop : ' || v_loop || ' cs');
    DBMS_OUTPUT.PUT_LINE('FORALL (bulk)   : ' || v_bulk || ' cs');
EXCEPTION
    WHEN OTHERS THEN
        log_error('COMPARE_BULK_VS_LOOP', SQLCODE, SQLERRM);
        RAISE;
END compare_bulk_vs_loop;
/
