-- Returns the IDs of the top N scoring students of a course/semester
-- as a nested table (collection). Uses BULK COLLECT.
-- Call:  SELECT * FROM TABLE(get_top_students('INSY8311','2026-FALL',3));
CREATE OR REPLACE FUNCTION get_top_students (
    p_course_id IN courses.course_id%TYPE,
    p_semester  IN enrollments.semester%TYPE,
    p_n         IN PLS_INTEGER
) RETURN t_number_tab
IS
    v_ids t_number_tab;
BEGIN
    IF p_n IS NULL OR p_n < 1 THEN
        RAISE_APPLICATION_ERROR(-20080, 'N must be a positive integer.');
    END IF;

    SELECT student_id
      BULK COLLECT INTO v_ids
      FROM (SELECT student_id
              FROM enrollments
             WHERE course_id = p_course_id
               AND semester  = p_semester
               AND score IS NOT NULL
             ORDER BY score DESC)
     WHERE ROWNUM <= p_n;

    RETURN v_ids;
END get_top_students;
/
