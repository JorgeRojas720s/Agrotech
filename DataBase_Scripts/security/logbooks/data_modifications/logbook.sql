-- Logbook Table
CREATE TABLE LOG_DATA_MODIFICATIONS (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50),
    action VARCHAR2(20),
    record_id NUMBER,
    old_data CLOB,
    new_data CLOB,
    username VARCHAR2(50),
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    ip_address VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_DATA_MOD START WITH 1 INCREMENT BY 1;
