-- Finds a student ID by (part of) the name.
-- Demonstrates NO_DATA_FOUND and TOO_MANY_ROWS being turned into clear errors.
CREATE OR REPLACE FUNCTION get_student_id_by_name (p_name IN VARCHAR2)
RETURN students.student_id%TYPE
IS
    v_id students.student_id%TYPE;
BEGIN
    SELECT student_id INTO v_id
      FROM students
     WHERE UPPER(full_name) LIKE '%' || UPPER(p_name) || '%';

    RETURN v_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20091, 'No student matches "' || p_name || '".');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20092, 'More than one student matches "' || p_name || '"; be more specific.');
END get_student_id_by_name;
/
