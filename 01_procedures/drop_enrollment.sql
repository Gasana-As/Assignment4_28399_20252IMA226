-- Removes an UNGRADED enrollment. Implicit cursor with DELETE (SQL%FOUND /
-- SQL%ROWCOUNT) and a user-defined exception for graded enrollments.
CREATE OR REPLACE PROCEDURE drop_enrollment (
    p_student_id IN students.student_id%TYPE,
    p_course_id  IN courses.course_id%TYPE,
    p_semester   IN enrollments.semester%TYPE
) IS
    v_score         enrollments.score%TYPE;
    v_rows          PLS_INTEGER;
    e_already_graded EXCEPTION;
BEGIN
    SELECT score INTO v_score
      FROM enrollments
     WHERE student_id = p_student_id
       AND course_id  = p_course_id
       AND semester   = p_semester;

    IF v_score IS NOT NULL THEN
        RAISE e_already_graded;
    END IF;

    DELETE FROM enrollments
     WHERE student_id = p_student_id
       AND course_id  = p_course_id
       AND semester   = p_semester;

    v_rows := SQL%ROWCOUNT;
    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Dropped enrollment. Rows deleted: ' || v_rows);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Enrollment not found for student ' || p_student_id || ' in ' || p_course_id || ' (' || p_semester || ').');
    WHEN e_already_graded THEN
        RAISE_APPLICATION_ERROR(-20021, 'Cannot drop: enrollment already has a score (' || v_score || ').');
    WHEN OTHERS THEN
        log_error('DROP_ENROLLMENT', SQLCODE, SQLERRM);
        RAISE;
END drop_enrollment;
/
