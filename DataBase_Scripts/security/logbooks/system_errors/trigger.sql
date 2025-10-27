-- Generic error handling procedure
CREATE OR REPLACE PROCEDURE LOG_SYSTEM_ERROR(
    p_error_code IN NUMBER,
    p_error_message IN VARCHAR2,
    p_table_name IN VARCHAR2,
    p_constraint_name IN VARCHAR2,
    p_sql_statement IN CLOB
) AS
BEGIN
    INSERT INTO LOG_SYSTEM_ERRORS (
        log_id, error_code, error_message, table_name,
        constraint_name, username, sql_statement
    ) VALUES (
        SEQ_LOG_ERRORS.NEXTVAL, p_error_code, p_error_message,
        p_table_name, p_constraint_name, USER, p_sql_statement
    );
END;
/