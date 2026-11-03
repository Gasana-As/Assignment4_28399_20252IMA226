-- Every block below is EXPECTED to fail; each prints the error that was raised.
-- Run after the schema/data are fresh (or after rolling back the success tests).
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 200

PROMPT ===== E1: student not found (NO_DATA_FOUND -> ORA-20001) =====
DECLARE v_id NUMBER;
BEGIN enroll_student(9999, 'INSY8311', '2026-FALL', v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E2: suspended student (user-defined exception -> ORA-20002) =====
DECLARE v_id NUMBER;
BEGIN enroll_student(1010, 'INSY8311', '2026-FALL', v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E3: course full (user-defined exception -> ORA-20003) =====
DECLARE v_id NUMBER;
BEGIN enroll_student(1009, 'MATH8001', '2026-SPR', v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E4: duplicate enrollment (DUP_VAL_ON_INDEX -> ORA-20004) =====
DECLARE v_id NUMBER;
BEGIN enroll_student(1001, 'INSY8311', '2026-FALL', v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E5: unknown course (ORA-20070 from get_seats_left) =====
DECLARE v_id NUMBER;
BEGIN enroll_student(1001, 'XXXX0000', '2026-FALL', v_id);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E6: invalid score 150 (ORA-20050) =====
DECLARE v_l VARCHAR2(1);
BEGIN update_score(1001, 'INSY8311', '2026-FALL', 150, v_l);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E7: update score, student not enrolled (ORA-20011) =====
DECLARE v_l VARCHAR2(1);
BEGIN update_score(1009, 'INSY8311', '2026-FALL', 70, v_l);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E8: drop already-graded enrollment (ORA-20021) =====
BEGIN drop_enrollment(1001, 'INSY8311', '2026-FALL');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E9: drop non-existent enrollment (ORA-20020) =====
BEGIN drop_enrollment(1009, 'INSY8311', '2026-FALL');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E10: bulk enroll with bad rows (SAVE EXCEPTIONS: 1 ok, 2 failed) =====
DECLARE
    v_ok PLS_INTEGER; v_fail PLS_INTEGER;
BEGIN
    -- 1001 = duplicate (ORA-00001), 1009 = valid, 9999 = unknown student (ORA-02291)
    bulk_enroll_students('INSY8311', '2026-FALL', t_number_tab(1001, 1009, 9999), v_ok, v_fail);
    DBMS_OUTPUT.PUT_LINE('OUT success=' || v_ok || ' failed=' || v_fail);
END;
/
SELECT source_name, error_code, error_message FROM error_log ORDER BY log_id;

PROMPT ===== E11: bulk enroll more students than seats (ORA-20032) =====
DECLARE
    v_ok PLS_INTEGER; v_fail PLS_INTEGER;
BEGIN
    bulk_enroll_students('MATH8001', '2026-SPR', t_number_tab(1004, 1005), v_ok, v_fail);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E12: bulk enroll with empty collection (ORA-20030) =====
DECLARE
    v_ok PLS_INTEGER; v_fail PLS_INTEGER;
BEGIN
    bulk_enroll_students('INSY8311', '2026-FALL', t_number_tab(), v_ok, v_fail);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E13: invalid curve bonus (ORA-20040) =====
DECLARE v_rows PLS_INTEGER;
BEGIN bulk_apply_curve('INSY8311', '2026-FALL', 50, v_rows);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E14: TOO_MANY_ROWS handled in function (ORA-20092) =====
BEGIN DBMS_OUTPUT.PUT_LINE(get_student_id_by_name('Jean'));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E15: NO_DATA_FOUND handled in function (ORA-20091) =====
BEGIN DBMS_OUTPUT.PUT_LINE(get_student_id_by_name('Zzzzz'));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E16: function errors (ORA-20050, 20060, 20070, 20080, 20090) =====
BEGIN DBMS_OUTPUT.PUT_LINE(get_letter_grade(NULL));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/
BEGIN DBMS_OUTPUT.PUT_LINE(calc_student_gpa(9999));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/
BEGIN DBMS_OUTPUT.PUT_LINE(get_seats_left('XXXX0000', '2026-FALL'));
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/
BEGIN DBMS_OUTPUT.PUT_LINE(get_top_students('INSY8311', '2026-FALL', 0).COUNT);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/
DECLARE v_s students%ROWTYPE;
BEGIN v_s := get_student_record(9999);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E17: reports on missing data (ORA-20090, ORA-20110) =====
BEGIN print_transcript(9999);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/
BEGIN course_report('XXXX0000', '2026-FALL');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== E18: invalid row count for performance demo (ORA-20120) =====
BEGIN compare_bulk_vs_loop(0);
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Expected error -> ' || SQLERRM);
END;
/

PROMPT ===== Error log contents =====
SELECT log_id, source_name, error_code, SUBSTR(error_message,1,90) AS msg FROM error_log ORDER BY log_id;

ROLLBACK;
