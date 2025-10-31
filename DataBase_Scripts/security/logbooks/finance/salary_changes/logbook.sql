-- Logbook Table for salary changes
CREATE TABLE LOG_SALARY_CHANGES (
    log_id NUMBER PRIMARY KEY,
    sal_id NUMBER,
    amount_old NUMBER(15,2),
    amount_new NUMBER(15,2),
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_SALARY START WITH 1 INCREMENT BY 1;