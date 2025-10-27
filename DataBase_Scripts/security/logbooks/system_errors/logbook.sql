-- Logbook Table
CREATE TABLE LOG_SYSTEM_ERRORS (
    log_id NUMBER PRIMARY KEY,
    error_code NUMBER,
    error_message VARCHAR2(400),
    table_name VARCHAR2(50),
    constraint_name VARCHAR2(50),
    error_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    sql_statement CLOB
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_ERRORS START WITH 1 INCREMENT BY 1;