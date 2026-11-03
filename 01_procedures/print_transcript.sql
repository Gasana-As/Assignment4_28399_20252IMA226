-- Prints a student's transcript. Uses: %ROWTYPE record (via function),
-- user-defined RECORD, explicit cursor with parameter (OPEN/FETCH/CLOSE).
CREATE OR REPLACE PROCEDURE print_transcript (
    p_student_id IN students.student_id%TYPE
) IS
    v_student students%ROWTYPE;

    TYPE t_transcript_rec IS RECORD (
        course_id    courses.course_id%TYPE,
        title        courses.title%TYPE,
        credits      courses.credits%TYPE,
        semester     enrollments.semester%TYPE,
        score        enrollments.score%TYPE,
        letter_grade enrollments.letter_grade%TYPE
    );
    v_rec   t_transcript_rec;
    v_count PLS_INTEGER := 0;
    v_gpa   NUMBER;

    CURSOR c_transcript (cp_student_id students.student_id%TYPE) IS
        SELECT c.course_id, c.title, c.credits, e.semester, e.score, e.letter_grade
          FROM enrollments e
          JOIN courses c ON c.course_id = e.course_id
         WHERE e.student_id = cp_student_id
         ORDER BY e.semester, c.course_id;
BEGIN
    v_student := get_student_record(p_student_id);    -- raises -20090 if missing

    DBMS_OUTPUT.PUT_LINE('TRANSCRIPT: ' || v_student.full_name || ' (' || v_student.student_id ||
                         ') - ' || v_student.department);
    DBMS_OUTPUT.PUT_LINE(RPAD('Semester',10) || RPAD('Course',10) || RPAD('Title',34) ||
                         LPAD('Cr',3) || LPAD('Score',8) || LPAD('Grade',7));

    OPEN c_transcript(p_student_id);
    LOOP
        FETCH c_transcript INTO v_rec;
        EXIT WHEN c_transcript%NOTFOUND;
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(RPAD(v_rec.semester,10) || RPAD(v_rec.course_id,10) || RPAD(v_rec.title,34) ||
                             LPAD(v_rec.credits,3) || LPAD(NVL(TO_CHAR(v_rec.score),'--'),8) ||
                             LPAD(NVL(v_rec.letter_grade,'-'),7));
    END LOOP;
    CLOSE c_transcript;

    v_gpa := calc_student_gpa(p_student_id);
    DBMS_OUTPUT.PUT_LINE('Courses: ' || v_count || ' | GPA: ' || NVL(TO_CHAR(v_gpa,'0.00'), 'N/A (no graded courses)'));
EXCEPTION
    WHEN OTHERS THEN
        IF c_transcript%ISOPEN THEN
            CLOSE c_transcript;
        END IF;
        log_error('PRINT_TRANSCRIPT', SQLCODE, SQLERRM);
        RAISE;
END print_transcript;
/
