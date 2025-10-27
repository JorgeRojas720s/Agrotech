-- Trigger for availabilities
CREATE OR REPLACE TRIGGER TRG_LOG_AVAILABILITY
    AFTER UPDATE ON TBL_AVAILABILITIES
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
BEGIN
    v_username := USER;
    
    IF :OLD.ava_available != :NEW.ava_available THEN
        INSERT INTO LOG_AVAILABILITY_CHANGES (
            log_id, ava_id, previous_status, new_status,
            username, reason
        ) VALUES (
            SEQ_LOG_AVAILABILITY.NEXTVAL, :OLD.ava_id,
            :OLD.ava_available, :NEW.ava_available,
            v_username, 'Automatic status change'
        );
    END IF;
END;
/