-- Logbook Table
CREATE TABLE LOG_LABORATORY_ANALYSIS (
    log_id NUMBER PRIMARY KEY,
    laa_id NUMBER,
    laa_technical_files_id NUMBER,
    results_old VARCHAR2(200),
    results_new VARCHAR2(200),
    observations_old VARCHAR2(200),
    observations_new VARCHAR2(200),
    analysis_date_old TIMESTAMP,
    analysis_date_new TIMESTAMP,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_LAB_ANALYSIS START WITH 1 INCREMENT BY 1;