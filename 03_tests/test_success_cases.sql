-- Run AFTER schema, sample data, procedures and functions are compiled.
-- Take one screenshot per numbered test (see screenshots/ folder).
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200

PROMPT ===== TEST 1: enroll_student (implicit cursor, %ROWTYPE, OUT param) =====
DECLARE
    v_id enrollments.enrollment_id%TYPE;
BEGIN
    enroll_student(1005, 'CSEN8101', '2026-FALL', v_id);
    DBMS_OUTPUT.PUT_LINE('OUT enrollment_id = ' || v_id);
END;
/

PROMPT ===== TEST 2: update_score (SQL%FOUND / SQL%ROWCOUNT, audit row) =====
DECLARE
    v_letter enrollments.letter_grade%TYPE;
BEGIN
    update_score(1006, 'SENG8215', '2026-FALL', 77.5, v_letter);
    DBMS_OUTPUT.PUT_LINE('OUT letter grade = ' || v_letter);
END;
/
SELECT * FROM grade_audit;

PROMPT ===== TEST 3: drop_enrollment (DELETE + SQL%FOUND) =====
BEGIN
    drop_enrollment(1005, 'CSEN8101', '2026-FALL');
END;
/

PROMPT ===== TEST 4: print_transcript (user-defined record + explicit cursor) =====
BEGIN
    print_transcript(1001);
END;
/

PROMPT ===== TEST 5: course_report (cursor FOR loop, VARRAY, associative array) =====
BEGIN
    course_report('INSY8311', '2026-FALL');
END;
/

PROMPT ===== TEST 6: bulk_enroll_students (FORALL, all rows succeed) =====
DECLARE
    v_ok   PLS_INTEGER;
    v_fail PLS_INTEGER;
BEGIN
    bulk_enroll_students('SENG8313', '2026-FALL', t_number_tab(1005, 1006, 1007), v_ok, v_fail);
    DBMS_OUTPUT.PUT_LINE('OUT success=' || v_ok || ' failed=' || v_fail);
END;
/

PROMPT ===== TEST 7: bulk_apply_curve (BULK COLLECT LIMIT + FORALL) =====
DECLARE
    v_rows PLS_INTEGER;
BEGIN
    bulk_apply_curve('INSY8311', '2026-FALL', 5, v_rows);
    DBMS_OUTPUT.PUT_LINE('OUT rows updated = ' || v_rows);
END;
/
BEGIN course_report('INSY8311', '2026-FALL'); END;
/

PROMPT ===== TEST 8: recalculate_all_gpa (BULK COLLECT + FORALL SAVE EXCEPTIONS) =====
DECLARE
    v_n PLS_INTEGER;
BEGIN
    recalculate_all_gpa(v_n);
END;
/
SELECT student_id, full_name, gpa FROM students ORDER BY student_id;

PROMPT ===== TEST 9: functions called from SQL and PL/SQL =====
SELECT get_letter_grade(85) AS letter, get_grade_points(85) AS points FROM dual;
SELECT calc_student_gpa(1001) AS gpa_1001 FROM dual;
SELECT get_seats_left('INSY8311', '2026-FALL') AS seats_left FROM dual;
SELECT s.student_id, s.full_name
  FROM TABLE(get_top_students('INSY8311', '2026-FALL', 3)) t
  JOIN students s ON s.student_id = t.COLUMN_VALUE;
DECLARE
    v_student students%ROWTYPE;
BEGIN
    v_student := get_student_record(1002);
    DBMS_OUTPUT.PUT_LINE('Record: ' || v_student.full_name || ', ' || v_student.email);
    DBMS_OUTPUT.PUT_LINE('ID by name "Uwase": ' || get_student_id_by_name('Uwase'));
END;
/

PROMPT ===== TEST 10: performance - row-by-row vs FORALL =====
BEGIN
    compare_bulk_vs_loop(20000);
END;
/

ROLLBACK;
