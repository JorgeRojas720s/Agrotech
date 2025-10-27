-- Logbook Table
CREATE TABLE LOG_CROP_HISTORY (
    log_id NUMBER PRIMARY KEY,
    hic_id NUMBER,
    hic_farm_id NUMBER,
    sowing_date_old TIMESTAMP,
    sowing_date_new TIMESTAMP,
    harvest_date_old TIMESTAMP,
    harvest_date_new TIMESTAMP,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_CROP_HISTORY START WITH 1 INCREMENT BY 1;