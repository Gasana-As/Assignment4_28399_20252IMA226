-- Returns a whole STUDENTS row as a %ROWTYPE record (PL/SQL callers only).
CREATE OR REPLACE FUNCTION get_student_record (
    p_student_id IN students.student_id%TYPE
) RETURN students%ROWTYPE
IS
    v_student students%ROWTYPE;
BEGIN
    SELECT * INTO v_student
      FROM students
     WHERE student_id = p_student_id;

    RETURN v_student;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20090, 'Student ' || p_student_id || ' does not exist.');
END get_student_record;
/
