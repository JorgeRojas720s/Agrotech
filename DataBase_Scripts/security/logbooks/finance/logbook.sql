-- Logbook Table for all financial transactions
CREATE TABLE LOG_FINANCIAL_TRANSACTIONS (
    log_id NUMBER PRIMARY KEY,
    transaction_type VARCHAR2(50), -- 'ACCOUNT_PAYMENT', 'COMMISSION', 'SALARY', 'CONSULTATION_FEE'
    reference_id NUMBER, -- ID from the related table
    amount_old NUMBER(12,2),
    amount_new NUMBER(12,2),
    status_old VARCHAR2(15),
    status_new VARCHAR2(15),
    person_id NUMBER,
    agronomist_id NUMBER,
    company_id NUMBER,
    transaction_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_FINANCIAL START WITH 1 INCREMENT BY 1;