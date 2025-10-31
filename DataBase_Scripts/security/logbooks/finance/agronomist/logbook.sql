-- Logbook Table for agronomist financial changes
CREATE TABLE LOG_AGRONOMIST_FINANCIAL (
    log_id NUMBER PRIMARY KEY,
    agr_id NUMBER,
    consult_price_old NUMBER(12,2),
    consult_price_new NUMBER(12,2),
    salary_id_old NUMBER,
    salary_id_new NUMBER,
    salary_amount_old NUMBER(15,2),
    salary_amount_new NUMBER(15,2),
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_AGRO_FINANCIAL START WITH 1 INCREMENT BY 1;
