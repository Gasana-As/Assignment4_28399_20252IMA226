-- Recomputes GPA for every student with graded courses.
-- One SELECT ... BULK COLLECT into two associative arrays, then one
-- FORALL UPDATE with SAVE EXCEPTIONS (bulk DML error handling).
CREATE OR REPLACE PROCEDURE recalculate_all_gpa (
    p_updated OUT PLS_INTEGER
) IS
    TYPE t_id_tab  IS TABLE OF students.student_id%TYPE INDEX BY PLS_INTEGER;
    TYPE t_gpa_tab IS TABLE OF students.gpa%TYPE        INDEX BY PLS_INTEGER;
    TYPE t_int_tab IS TABLE OF PLS_INTEGER              INDEX BY PLS_INTEGER;

    v_ids      t_id_tab;
    v_gpas     t_gpa_tab;
    v_err_idx  t_int_tab;
    v_err_code t_int_tab;
    v_n        PLS_INTEGER;

    e_bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
    p_updated := 0;

    SELECT e.student_id,
           ROUND(SUM(c.credits * get_grade_points(e.score)) / SUM(c.credits), 2)
      BULK COLLECT INTO v_ids, v_gpas
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.score IS NOT NULL
     GROUP BY e.student_id;

    IF v_ids.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No graded enrollments found; nothing to update.');
        RETURN;
    END IF;

    FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
        UPDATE students SET gpa = v_gpas(i) WHERE student_id = v_ids(i);

    p_updated := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('GPA recalculated for ' || p_updated || ' student(s).');
EXCEPTION
    WHEN e_bulk_errors THEN
        v_n := SQL%BULK_EXCEPTIONS.COUNT;
        FOR j IN 1 .. v_n LOOP
            v_err_idx(j)  := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
            v_err_code(j) := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
        END LOOP;
        FOR j IN 1 .. v_n LOOP
            log_error('RECALCULATE_ALL_GPA', -v_err_code(j),
                      'student ' || v_ids(v_err_idx(j)) || ': ' || SQLERRM(-v_err_code(j)));
        END LOOP;
        RAISE_APPLICATION_ERROR(-20042, 'GPA recalculation had ' || v_n || ' bulk error(s); see ERROR_LOG.');
    WHEN OTHERS THEN
        log_error('RECALCULATE_ALL_GPA', SQLCODE, SQLERRM);
        RAISE;
END recalculate_all_gpa;
/
