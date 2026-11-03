-- Sample data. Letter grades follow the scale: A>=90, B>=80, C>=70, D>=60, F<60

INSERT INTO students (student_id, full_name, email, department, status) VALUES (1001,'Aline Uwase','aline.uwase@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1002,'Eric Nshuti','eric.nshuti@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1003,'Jean Claude Habimana','jc.habimana@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1004,'Grace Mukamana','grace.mukamana@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1005,'Jean Paul Uwimana','jp.uwimana@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1006,'Diane Ingabire','diane.ingabire@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1007,'Patrick Niyonzima','patrick.niyonzima@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1008,'Sandrine Mutesi','sandrine.mutesi@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1009,'Olivier Kamanzi','olivier.kamanzi@auca.ac.rw','IT','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1010,'Brian Rukundo','brian.rukundo@auca.ac.rw','IT','SUSPENDED');

INSERT INTO courses (course_id, title, credits, capacity) VALUES ('INSY8311','Database Development with PL/SQL',3,10);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('SENG8215','Software Engineering',3,10);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('SENG8313','Management Information Systems',3,10);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('CSEN8101','Object-Oriented Programming',4,10);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('MATH8001','Discrete Mathematics',2,3);

INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1001,'INSY8311','2026-FALL',92,'A');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1002,'INSY8311','2026-FALL',85,'B');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1003,'INSY8311','2026-FALL',74,'C');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1004,'INSY8311','2026-FALL',58,'F');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1001,'SENG8215','2026-FALL',88,'B');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1002,'SENG8215','2026-FALL',91,'A');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1005,'SENG8215','2026-FALL',67,'D');
INSERT INTO enrollments (student_id, course_id, semester) VALUES (1006,'SENG8215','2026-FALL');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1003,'CSEN8101','2026-FALL',79,'C');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1004,'CSEN8101','2026-FALL',83,'B');
INSERT INTO enrollments (student_id, course_id, semester) VALUES (1007,'CSEN8101','2026-FALL');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1001,'MATH8001','2026-SPR',95,'A');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1002,'MATH8001','2026-SPR',81,'B');
INSERT INTO enrollments (student_id, course_id, semester, score, letter_grade) VALUES (1008,'MATH8001','2026-SPR',70,'C');

COMMIT;
