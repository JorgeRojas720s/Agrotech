-- Logbook Table
CREATE TABLE LOG_AGRONOMIST_CHANGES (
    log_id NUMBER PRIMARY KEY,
    agr_id NUMBER,
    salary_old NUMBER(15,2),
    salary_new NUMBER(15,2),
    company_old NUMBER,
    company_new NUMBER,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_AGRONOMISTS START WITH 1 INCREMENT BY 1;