-- Enrolls many students at once using FORALL ... SAVE EXCEPTIONS.
-- Good rows are inserted; bad rows (duplicates, unknown student IDs) are
-- reported and logged instead of aborting the whole batch.
-- NOTE: the caller decides COMMIT / ROLLBACK.
CREATE OR REPLACE PROCEDURE bulk_enroll_students (
    p_course_id     IN  courses.course_id%TYPE,
    p_semester      IN  enrollments.semester%TYPE,
    p_student_ids   IN  t_number_tab,
    p_success_count OUT PLS_INTEGER,
    p_failed_count  OUT PLS_INTEGER
) IS
    e_bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);

    TYPE t_int_tab IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    v_err_idx  t_int_tab;
    v_err_code t_int_tab;
    v_n        PLS_INTEGER;
    v_seats    NUMBER;
BEGIN
    p_success_count := 0;
    p_failed_count  := 0;

    IF p_student_ids IS NULL OR p_student_ids.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20030, 'No student IDs supplied.');
    END IF;

    v_seats := get_seats_left(p_course_id, p_semester);   -- raises -20070 if no course
    IF p_student_ids.COUNT > v_seats THEN
        RAISE_APPLICATION_ERROR(-20032, 'Only ' || v_seats || ' seat(s) left in ' || p_course_id ||
                                ' but ' || p_student_ids.COUNT || ' students supplied.');
    END IF;

    BEGIN
        FORALL i IN INDICES OF p_student_ids SAVE EXCEPTIONS
            INSERT INTO enrollments (student_id, course_id, semester)
            VALUES (p_student_ids(i), p_course_id, p_semester);

        p_success_count := SQL%ROWCOUNT;
    EXCEPTION
        WHEN e_bulk_errors THEN
            -- copy the error info into locals first (logging runs other SQL)
            v_n := SQL%BULK_EXCEPTIONS.COUNT;
            FOR j IN 1 .. v_n LOOP
                v_err_idx(j)  := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
                v_err_code(j) := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
            END LOOP;

            p_failed_count  := v_n;
            p_success_count := p_student_ids.COUNT - v_n;

            FOR j IN 1 .. v_n LOOP
                DBMS_OUTPUT.PUT_LINE('  Failed student ' || p_student_ids(v_err_idx(j)) || ': ' ||
                                     SQLERRM(-v_err_code(j)));
                log_error('BULK_ENROLL_STUDENTS', -v_err_code(j),
                          'student ' || p_student_ids(v_err_idx(j)) || ': ' || SQLERRM(-v_err_code(j)));
            END LOOP;
    END;

    DBMS_OUTPUT.PUT_LINE('Bulk enroll finished: ' || p_success_count || ' succeeded, ' ||
                         p_failed_count || ' failed.');
EXCEPTION
    WHEN OTHERS THEN
        log_error('BULK_ENROLL_STUDENTS', SQLCODE, SQLERRM);
        RAISE;
END bulk_enroll_students;
/
