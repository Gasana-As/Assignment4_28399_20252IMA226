-- =====================================================================
-- Student Registration and Grading System - Schema
-- Requires Oracle 12c+ (identity columns).
-- =====================================================================

-- Optional clean-up so the script can be re-run:
-- DROP TABLE perf_test PURGE;   DROP TABLE error_log PURGE;
-- DROP TABLE grade_audit PURGE; DROP TABLE enrollments PURGE;
-- DROP TABLE courses PURGE;     DROP TABLE students PURGE;
-- DROP TYPE t_number_tab;

CREATE TABLE students (
    student_id  NUMBER(8)     CONSTRAINT pk_students PRIMARY KEY,
    full_name   VARCHAR2(100) NOT NULL,
    email       VARCHAR2(120) NOT NULL CONSTRAINT uq_students_email UNIQUE,
    department  VARCHAR2(50)  NOT NULL,
    status      VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL
                CONSTRAINT ck_students_status CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED')),
    gpa         NUMBER(3,2)   CONSTRAINT ck_students_gpa CHECK (gpa BETWEEN 0 AND 4)
);

CREATE TABLE courses (
    course_id  VARCHAR2(10)  CONSTRAINT pk_courses PRIMARY KEY,
    title      VARCHAR2(80)  NOT NULL,
    credits    NUMBER(1)     NOT NULL CONSTRAINT ck_courses_credits CHECK (credits BETWEEN 1 AND 6),
    capacity   NUMBER(3)     NOT NULL CONSTRAINT ck_courses_capacity CHECK (capacity > 0)
);

CREATE TABLE enrollments (
    enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_enrollments PRIMARY KEY,
    student_id    NUMBER(8)    NOT NULL CONSTRAINT fk_enr_student REFERENCES students(student_id),
    course_id     VARCHAR2(10) NOT NULL CONSTRAINT fk_enr_course  REFERENCES courses(course_id),
    semester      VARCHAR2(10) NOT NULL,
    score         NUMBER(5,2)  CONSTRAINT ck_enr_score CHECK (score BETWEEN 0 AND 100),
    letter_grade  VARCHAR2(1)  CONSTRAINT ck_enr_letter CHECK (letter_grade IN ('A','B','C','D','F')),
    enrolled_on   DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, semester)
);

CREATE TABLE grade_audit (
    audit_id      NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_grade_audit PRIMARY KEY,
    enrollment_id NUMBER NOT NULL CONSTRAINT fk_audit_enr REFERENCES enrollments(enrollment_id),
    old_score     NUMBER(5,2),
    new_score     NUMBER(5,2),
    changed_by    VARCHAR2(30) DEFAULT USER NOT NULL,
    changed_on    TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE error_log (
    log_id        NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_error_log PRIMARY KEY,
    source_name   VARCHAR2(60),
    error_code    NUMBER,
    error_message VARCHAR2(4000),
    logged_on     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Scratch table used only by the bulk-vs-loop performance demo
CREATE TABLE perf_test (
    id      NUMBER,
    payload VARCHAR2(50)
);

-- Schema-level nested table type (used by procedures AND functions)
CREATE OR REPLACE TYPE t_number_tab AS TABLE OF NUMBER;
/
