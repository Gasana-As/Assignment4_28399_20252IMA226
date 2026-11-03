-- Credit-weighted GPA over graded enrollments.
-- Returns NULL (not 0) when the student has no graded courses yet, because
-- 0.00 would be a misleading result. Unknown student -> error.
CREATE OR REPLACE FUNCTION calc_student_gpa (
    p_student_id IN students.student_id%TYPE
) RETURN NUMBER
IS
    v_id  students.student_id%TYPE;
    v_gpa NUMBER;
BEGIN
    SELECT student_id INTO v_id
      FROM students
     WHERE student_id = p_student_id;

    SELECT SUM(c.credits * get_grade_points(e.score)) / NULLIF(SUM(c.credits), 0)
      INTO v_gpa
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = p_student_id
       AND e.score IS NOT NULL;

    RETURN ROUND(v_gpa, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20060, 'Student ' || p_student_id || ' does not exist.');
END calc_student_gpa;
/
