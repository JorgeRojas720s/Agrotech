-- Trigger for salary changes
CREATE OR REPLACE TRIGGER TRG_LOG_SALARY_CHANGES
    AFTER UPDATE ON TBL_SALARIES
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
BEGIN
    v_username := USER;
    
    IF :OLD.sal_amount != :NEW.sal_amount THEN
        INSERT INTO LOG_SALARY_CHANGES (
            log_id, sal_id, amount_old, amount_new,
            username, action
        ) VALUES (
            SEQ_LOG_SALARY.NEXTVAL, :OLD.sal_id,
            :OLD.sal_amount, :NEW.sal_amount, v_username, 'UPDATE'
        );
    END IF;
END;
/