-- Logbook Table for account payments
CREATE TABLE LOG_ACCOUNT_PAYMENTS (
    log_id NUMBER PRIMARY KEY,
    acc_id NUMBER,
    amount_old NUMBER(12,2),
    amount_new NUMBER(12,2),
    status_old VARCHAR2(15),
    status_new VARCHAR2(15),
    person_id NUMBER,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_ACCOUNTS START WITH 1 INCREMENT BY 1;