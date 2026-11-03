-- Converts a score to grade points on a 4.0 scale (A=4 ... F=0).
CREATE OR REPLACE FUNCTION get_grade_points (p_score IN NUMBER)
RETURN NUMBER DETERMINISTIC
IS
BEGIN
    RETURN CASE get_letter_grade(p_score)
               WHEN 'A' THEN 4
               WHEN 'B' THEN 3
               WHEN 'C' THEN 2
               WHEN 'D' THEN 1
               ELSE 0
           END;
END get_grade_points;
/
