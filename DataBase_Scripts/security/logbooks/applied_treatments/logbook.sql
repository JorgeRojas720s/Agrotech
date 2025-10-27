-- Logbook Table
CREATE TABLE LOG_APPLIED_TREATMENTS (
    log_id NUMBER PRIMARY KEY,
    txt_technical_file_id NUMBER,
    txt_treatments_id NUMBER,
    treatment_name VARCHAR2(50),
    treatment_type VARCHAR2(45),
    application_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_TREATMENTS START WITH 1 INCREMENT BY 1;