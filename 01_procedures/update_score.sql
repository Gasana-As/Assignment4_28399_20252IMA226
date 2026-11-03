-- Records/updates a score. Uses implicit cursor attributes SQL%FOUND,
-- SQL%NOTFOUND, SQL%ROWCOUNT, and writes an audit row.
CREATE OR REPLACE PROCEDURE update_score (
    p_student_id   IN  students.student_id%TYPE,
    p_course_id    IN  courses.course_id%TYPE,
    p_semester     IN  enrollments.semester%TYPE,
    p_score        IN  NUMBER,
    p_letter_grade OUT enrollments.letter_grade%TYPE
) IS
    v_enrollment_id enrollments.enrollment_id%TYPE;
    v_old_score     enrollments.score%TYPE;
    v_rows          PLS_INTEGER;
BEGIN
    p_letter_grade := get_letter_grade(p_score);      -- validates 0..100

    SELECT enrollment_id, score
      INTO v_enrollment_id, v_old_score
      FROM enrollments
     WHERE student_id = p_student_id
       AND course_id  = p_course_id
       AND semester   = p_semester
       FOR UPDATE;                                    -- NO_DATA_FOUND if not enrolled

    UPDATE enrollments
       SET score = p_score,
           letter_grade = p_letter_grade
     WHERE enrollment_id = v_enrollment_id;

    v_rows := SQL%ROWCOUNT;                           -- capture before next DML
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Score update affected no rows.');
    END IF;

    INSERT INTO grade_audit (enrollment_id, old_score, new_score)
    VALUES (v_enrollment_id, v_old_score, p_score);

    DBMS_OUTPUT.PUT_LINE('Score updated: ' || NVL(TO_CHAR(v_old_score), 'none') || ' -> ' || p_score ||
                         ' (' || p_letter_grade || '). Rows updated: ' || v_rows);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'No enrollment for student ' || p_student_id || ' in ' || p_course_id || ' (' || p_semester || ').');
    WHEN OTHERS THEN
        log_error('UPDATE_SCORE', SQLCODE, SQLERRM);
        RAISE;
END update_score;
/
