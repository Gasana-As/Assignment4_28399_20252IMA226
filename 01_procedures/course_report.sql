-- Class roster + statistics. Uses: cursor FOR loop with parameters, VARRAY
-- (grade labels), associative array indexed by VARCHAR2 (grade counts).
CREATE OR REPLACE PROCEDURE course_report (
    p_course_id IN courses.course_id%TYPE,
    p_semester  IN enrollments.semester%TYPE
) IS
    v_course courses%ROWTYPE;

    TYPE t_letters IS VARRAY(5) OF VARCHAR2(1);
    v_letters t_letters := t_letters('A','B','C','D','F');

    TYPE t_counts IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(1);
    v_counts t_counts;

    v_total    NUMBER      := 0;
    v_graded   PLS_INTEGER := 0;
    v_enrolled PLS_INTEGER := 0;

    CURSOR c_roster (cp_course courses.course_id%TYPE, cp_sem enrollments.semester%TYPE) IS
        SELECT s.student_id, s.full_name, e.score, e.letter_grade
          FROM enrollments e
          JOIN students s ON s.student_id = e.student_id
         WHERE e.course_id = cp_course
           AND e.semester  = cp_sem
         ORDER BY e.score DESC NULLS LAST, s.full_name;
BEGIN
    SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;

    FOR i IN 1 .. v_letters.COUNT LOOP
        v_counts(v_letters(i)) := 0;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('COURSE REPORT: ' || v_course.course_id || ' - ' || v_course.title || ' (' || p_semester || ')');

    FOR r IN c_roster(p_course_id, p_semester) LOOP
        v_enrolled := v_enrolled + 1;
        DBMS_OUTPUT.PUT_LINE(RPAD(r.student_id,8) || RPAD(r.full_name,26) ||
                             LPAD(NVL(TO_CHAR(r.score),'--'),8) || LPAD(NVL(r.letter_grade,'-'),4));
        IF r.score IS NOT NULL AND r.letter_grade IS NOT NULL THEN
            v_graded := v_graded + 1;
            v_total  := v_total + r.score;
            v_counts(r.letter_grade) := v_counts(r.letter_grade) + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Enrolled: ' || v_enrolled || ' / ' || v_course.capacity || ' | Graded: ' || v_graded);
    IF v_graded > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Class average: ' || ROUND(v_total / v_graded, 2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Class average: N/A (no graded students)');
    END IF;
    FOR i IN 1 .. v_letters.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  Grade ' || v_letters(i) || ': ' || v_counts(v_letters(i)));
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20110, 'Course ' || p_course_id || ' does not exist.');
    WHEN OTHERS THEN
        log_error('COURSE_REPORT', SQLCODE, SQLERRM);
        RAISE;
END course_report;
/
