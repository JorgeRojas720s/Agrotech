-- Generic trigger template for critical tables
CREATE OR REPLACE TRIGGER TRG_LOG_COMPANIES
    AFTER INSERT OR UPDATE OR DELETE ON TBL_COMPANIES
    FOR EACH ROW
DECLARE
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF DELETING THEN
        v_old_data := 'ID: ' || :OLD.com_id || ', Name: ' || :OLD.com_name;
        INSERT INTO LOG_DATA_MODIFICATIONS (
            log_id, table_name, action, record_id, old_data, username
        ) VALUES (
            SEQ_LOG_DATA_MOD.NEXTVAL, 'TBL_COMPANIES', 'DELETE',
            :OLD.com_id, v_old_data, USER
        );
    ELSIF INSERTING THEN
        v_new_data := 'ID: ' || :NEW.com_id || ', Name: ' || :NEW.com_name;
        INSERT INTO LOG_DATA_MODIFICATIONS (
            log_id, table_name, action, record_id, new_data, username
        ) VALUES (
            SEQ_LOG_DATA_MOD.NEXTVAL, 'TBL_COMPANIES', 'INSERT',
            :NEW.com_id, v_new_data, USER
        );
    ELSIF UPDATING THEN
        v_old_data := 'ID: ' || :OLD.com_id || ', Name: ' || :OLD.com_name;
        v_new_data := 'ID: ' || :NEW.com_id || ', Name: ' || :NEW.com_name;
        INSERT INTO LOG_DATA_MODIFICATIONS (
            log_id, table_name, action, record_id, old_data, new_data, username
        ) VALUES (
            SEQ_LOG_DATA_MOD.NEXTVAL, 'TBL_COMPANIES', 'UPDATE',
            :OLD.com_id, v_old_data, v_new_data, USER
        );
    END IF;
END;
/