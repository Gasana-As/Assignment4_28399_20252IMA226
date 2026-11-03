-- Returns remaining seats in a course for a semester.
-- Demonstrates SELECT INTO with the predefined NO_DATA_FOUND exception.
CREATE OR REPLACE FUNCTION get_seats_left (
    p_course_id IN courses.course_id%TYPE,
    p_semester  IN enrollments.semester%TYPE
) RETURN NUMBER
IS
    v_capacity courses.capacity%TYPE;
    v_enrolled NUMBER;
BEGIN
    SELECT capacity INTO v_capacity
      FROM courses
     WHERE course_id = p_course_id;

    SELECT COUNT(*) INTO v_enrolled
      FROM enrollments
     WHERE course_id = p_course_id
       AND semester  = p_semester;

    RETURN v_capacity - v_enrolled;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20070, 'Course ' || p_course_id || ' does not exist.');
END get_seats_left;
/
