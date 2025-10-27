-- Trigger for field inspections
CREATE OR REPLACE TRIGGER TRG_LOG_INSPECTIONS
    AFTER INSERT OR UPDATE ON TBL_FIELD_INSPECTIONS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
BEGIN
    v_username := USER;
    
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_FIELD_INSPECTIONS (
            log_id, fii_id, fii_crops_id, fii_agronomists_id,
            soil_ph_new, humidity_new, temperature_new, nutrient_level_new,
            username, action
        ) VALUES (
            SEQ_LOG_INSPECTIONS.NEXTVAL, :NEW.fii_id, :NEW.fii_crops_id, 
            :NEW.fii_agronomists_id, :NEW.fii_soil_ph, :NEW.fii_humidity,
            :NEW.fii_ambient_temperature, :NEW.fii_nutrient_level,
            v_username, v_action
        );
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_FIELD_INSPECTIONS (
            log_id, fii_id, fii_crops_id, fii_agronomists_id,
            soil_ph_old, soil_ph_new,
            humidity_old, humidity_new,
            temperature_old, temperature_new,
            nutrient_level_old, nutrient_level_new,
            username, action
        ) VALUES (
            SEQ_LOG_INSPECTIONS.NEXTVAL, :OLD.fii_id, :OLD.fii_crops_id, 
            :OLD.fii_agronomists_id, :OLD.fii_soil_ph, :NEW.fii_soil_ph,
            :OLD.fii_humidity, :NEW.fii_humidity,
            :OLD.fii_ambient_temperature, :NEW.fii_ambient_temperature,
            :OLD.fii_nutrient_level, :NEW.fii_nutrient_level,
            v_username, v_action
        );
    END IF;
END;
/