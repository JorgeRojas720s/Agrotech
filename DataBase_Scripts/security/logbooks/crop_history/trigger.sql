-- Trigger for crop history
CREATE OR REPLACE TRIGGER TRG_LOG_CROP_HISTORY
    AFTER INSERT OR UPDATE ON TBL_HISTORY_CROPS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
BEGIN
    v_username := USER;
    
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_CROP_HISTORY (
            log_id, hic_id, hic_farm_id,
            sowing_date_new, harvest_date_new,
            username, action
        ) VALUES (
            SEQ_LOG_CROP_HISTORY.NEXTVAL, :NEW.hic_id, :NEW.hic_farm_id,
            :NEW.hic_sowing_date, :NEW.hic_harvest_date,
            v_username, v_action
        );
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_CROP_HISTORY (
            log_id, hic_id, hic_farm_id,
            sowing_date_old, sowing_date_new,
            harvest_date_old, harvest_date_new,
            username, action
        ) VALUES (
            SEQ_LOG_CROP_HISTORY.NEXTVAL, :OLD.hic_id, :OLD.hic_farm_id,
            :OLD.hic_sowing_date, :NEW.hic_sowing_date,
            :OLD.hic_harvest_date, :NEW.hic_harvest_date,
            v_username, v_action
        );
    END IF;
END;
/