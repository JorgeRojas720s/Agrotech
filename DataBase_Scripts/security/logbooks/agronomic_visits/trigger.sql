-- Trigger for visits
CREATE OR REPLACE TRIGGER TRG_LOG_VISITS
    AFTER INSERT OR UPDATE OR DELETE ON TBL_VISITS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
BEGIN
    -- Get current user
    v_username := USER;
    
    -- Determine action
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_AGRONOMIC_VISITS (
            log_id, vis_id, vis_producer_id, vis_available_id,
            vis_attendance_new, vis_slots_new,
            username, action
        ) VALUES (
            SEQ_LOG_VISITS.NEXTVAL, :NEW.vis_id, :NEW.vis_producer_id, 
            :NEW.vis_available_id, :NEW.vis_attendance, :NEW.vis_slots,
            v_username, v_action
        );
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_AGRONOMIC_VISITS (
            log_id, vis_id, vis_producer_id, vis_available_id,
            vis_attendance_old, vis_attendance_new,
            vis_slots_old, vis_slots_new,
            username, action
        ) VALUES (
            SEQ_LOG_VISITS.NEXTVAL, :OLD.vis_id, :OLD.vis_producer_id, 
            :OLD.vis_available_id, :OLD.vis_attendance, :NEW.vis_attendance,
            :OLD.vis_slots, :NEW.vis_slots, v_username, v_action
        );
    ELSIF DELETING THEN
        v_action := 'DELETE';
        INSERT INTO LOG_AGRONOMIC_VISITS (
            log_id, vis_id, vis_producer_id, vis_available_id,
            vis_attendance_old, vis_slots_old,
            username, action
        ) VALUES (
            SEQ_LOG_VISITS.NEXTVAL, :OLD.vis_id, :OLD.vis_producer_id, 
            :OLD.vis_available_id, :OLD.vis_attendance, :OLD.vis_slots,
            v_username, v_action
        );
    END IF;
END;
/