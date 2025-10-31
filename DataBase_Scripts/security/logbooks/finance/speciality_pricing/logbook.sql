-- Logbook Table for specialty pricing changes
CREATE TABLE LOG_SPECIALTY_PRICING (
    log_id NUMBER PRIMARY KEY,
    spe_id NUMBER,
    price_old NUMBER(12,2),
    price_new NUMBER(12,2),
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_SPECIALTY_PRICING START WITH 1 INCREMENT BY 1;
