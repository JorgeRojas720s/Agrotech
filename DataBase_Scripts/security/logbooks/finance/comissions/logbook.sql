-- Logbook Table for commissions
CREATE TABLE LOG_COMMISSIONS (
    log_id NUMBER PRIMARY KEY,
    com_id NUMBER,
    amount_old NUMBER(12,2),
    amount_new NUMBER(12,2),
    agronomist_id NUMBER,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_COMMISSIONS START WITH 1 INCREMENT BY 1;