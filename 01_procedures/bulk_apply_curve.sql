-- Adds bonus points to all graded students of a course/semester.
-- Explicit cursor + BULK COLLECT ... LIMIT (batches of 100, bounded memory)
-- + FORALL for the UPDATE and the audit INSERT.
CREATE OR REPLACE PROCEDURE bulk_apply_curve (
    p_course_id    IN  courses.course_id%TYPE,
    p_semester     IN  enrollments.semester%TYPE,
    p_bonus        IN  NUMBER,
    p_rows_updated OUT PLS_INTEGER
) IS
    TYPE t_id_tab     IS TABLE OF enrollments.enrollment_id%TYPE INDEX BY PLS_INTEGER;
    TYPE t_score_tab  IS TABLE OF enrollments.score%TYPE         INDEX BY PLS_INTEGER;
    TYPE t_letter_tab IS TABLE OF enrollments.letter_grade%TYPE  INDEX BY PLS_INTEGER;

    v_ids     t_id_tab;
    v_old     t_score_tab;
    v_new     t_score_tab;
    v_letters t_letter_tab;
    v_batch   PLS_INTEGER;

    c_batch_size CONSTANT PLS_INTEGER := 100;

    CURSOR c_graded IS
        SELECT enrollment_id, score
          FROM enrollments
         WHERE course_id = p_course_id
           AND semester  = p_semester
           AND score IS NOT NULL
           FOR UPDATE;
BEGIN
    p_rows_updated := 0;

    IF p_bonus IS NULL OR p_bonus NOT BETWEEN 0 AND 20 THEN
        RAISE_APPLICATION_ERROR(-20040, 'Bonus must be between 0 and 20 points.');
    END IF;

    OPEN c_graded;
    LOOP
        FETCH c_graded BULK COLLECT INTO v_ids, v_old LIMIT c_batch_size;
        EXIT WHEN v_ids.COUNT = 0;

        FOR i IN 1 .. v_ids.COUNT LOOP
            v_new(i)     := LEAST(v_old(i) + p_bonus, 100);   -- never above 100
            v_letters(i) := get_letter_grade(v_new(i));
        END LOOP;

        FORALL i IN 1 .. v_ids.COUNT
            UPDATE enrollments
               SET score = v_new(i), letter_grade = v_letters(i)
             WHERE enrollment_id = v_ids(i);
        v_batch := SQL%ROWCOUNT;                              -- rows of the UPDATE

        FORALL i IN 1 .. v_ids.COUNT
            INSERT INTO grade_audit (enrollment_id, old_score, new_score)
            VALUES (v_ids(i), v_old(i), v_new(i));

        p_rows_updated := p_rows_updated + v_batch;
    END LOOP;
    CLOSE c_graded;

    DBMS_OUTPUT.PUT_LINE('Curve of +' || p_bonus || ' applied to ' || p_rows_updated ||
                         ' enrollment(s) in ' || p_course_id || ' (' || p_semester || ').');
EXCEPTION
    WHEN OTHERS THEN
        IF c_graded%ISOPEN THEN
            CLOSE c_graded;
        END IF;
        log_error('BULK_APPLY_CURVE', SQLCODE, SQLERRM);
        RAISE;
END bulk_apply_curve;
/
