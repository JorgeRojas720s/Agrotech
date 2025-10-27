CREATE TABLE LOG_FIELD_INSPECTIONS (
    log_id NUMBER PRIMARY KEY,
    fii_id NUMBER,
    fii_crops_id NUMBER,
    fii_agronomists_id NUMBER,
    soil_ph_old NUMBER,
    soil_ph_new NUMBER,
    humidity_old NUMBER,
    humidity_new NUMBER,
    temperature_old NUMBER(10,2),
    temperature_new NUMBER(10,2),
    nutrient_level_old VARCHAR2(25),
    nutrient_level_new VARCHAR2(25),
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence
CREATE SEQUENCE SEQ_LOG_INSPECTIONS START WITH 1 INCREMENT BY 1;