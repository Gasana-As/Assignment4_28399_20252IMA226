-- Enrolls one student in a course. Uses: %ROWTYPE record, implicit cursor
-- (SQL%ROWCOUNT), OUT parameter, user-defined + predefined exceptions.
CREATE OR REPLACE PROCEDURE enroll_student (
    p_student_id    IN  students.student_id%TYPE,
    p_course_id     IN  courses.course_id%TYPE,
    p_semester      IN  enrollments.semester%TYPE,
    p_enrollment_id OUT enrollments.enrollment_id%TYPE
) IS
    v_student          students%ROWTYPE;
    v_rows             PLS_INTEGER;
    e_student_inactive EXCEPTION;
    e_course_full      EXCEPTION;
BEGIN
    SELECT * INTO v_student
      FROM students
     WHERE student_id = p_student_id;                 -- NO_DATA_FOUND if missing

    IF v_student.status <> 'ACTIVE' THEN
        RAISE e_student_inactive;
    END IF;

    IF get_seats_left(p_course_id, p_semester) <= 0 THEN
        RAISE e_course_full;
    END IF;

    INSERT INTO enrollments (student_id, course_id, semester)
    VALUES (p_student_id, p_course_id, p_semester)
    RETURNING enrollment_id INTO p_enrollment_id;

    v_rows := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Enrolled ' || v_student.full_name || ' in ' || p_course_id ||
                         ' (' || p_semester || '). Rows inserted: ' || v_rows ||
                         ', enrollment_id=' || p_enrollment_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Student ' || p_student_id || ' does not exist.');
    WHEN e_student_inactive THEN
        RAISE_APPLICATION_ERROR(-20002, 'Student ' || p_student_id || ' is not ACTIVE (status=' || v_student.status || ').');
    WHEN e_course_full THEN
        RAISE_APPLICATION_ERROR(-20003, 'Course ' || p_course_id || ' is full for ' || p_semester || '.');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20004, 'Student ' || p_student_id || ' is already enrolled in ' || p_course_id || ' for ' || p_semester || '.');
    WHEN OTHERS THEN
        log_error('ENROLL_STUDENT', SQLCODE, SQLERRM);
        RAISE;
END enroll_student;
/
