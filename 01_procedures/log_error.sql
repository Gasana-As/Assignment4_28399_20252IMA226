-- Writes an error to ERROR_LOG in an autonomous transaction, so the log
-- entry survives even if the caller rolls back.
CREATE OR REPLACE PROCEDURE log_error (
    p_source  IN VARCHAR2,
    p_code    IN NUMBER,
    p_message IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO error_log (source_name, error_code, error_message)
    VALUES (p_source, p_code, SUBSTR(p_message, 1, 4000));
    COMMIT;
END log_error;
/
