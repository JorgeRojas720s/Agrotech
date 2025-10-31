-- Trigger for commissions
CREATE OR REPLACE TRIGGER TRG_LOG_COMMISSIONS
    AFTER INSERT OR UPDATE ON TBL_COMISSIONS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
    v_company_id NUMBER;
BEGIN
    v_username := USER;
    
    -- Get company ID from agronomist
    BEGIN
        SELECT agr_company_id INTO v_company_id
        FROM TBL_AGRONOMISTS
        WHERE agr_id = :NEW.com_agronomist_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_company_id := NULL;
    END;
    
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_COMMISSIONS (
            log_id, com_id, amount_new, agronomist_id,
            username, action
        ) VALUES (
            SEQ_LOG_COMMISSIONS.NEXTVAL, :NEW.com_id, :NEW.com_amount,
            :NEW.com_agronomist_id, v_username, v_action
        );
        
        -- Also log in general financial transactions
        INSERT INTO LOG_FINANCIAL_TRANSACTIONS (
            log_id, transaction_type, reference_id, amount_new,
            agronomist_id, company_id, username, action
        ) VALUES (
            SEQ_LOG_FINANCIAL.NEXTVAL, 'COMMISSION', :NEW.com_id,
            :NEW.com_amount, :NEW.com_agronomist_id, v_company_id,
            v_username, v_action
        );
        
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_COMMISSIONS (
            log_id, com_id, amount_old, amount_new, agronomist_id,
            username, action
        ) VALUES (
            SEQ_LOG_COMMISSIONS.NEXTVAL, :OLD.com_id, :OLD.com_amount, :NEW.com_amount,
            :OLD.com_agronomist_id, v_username, v_action
        );
        
        -- Also log in general financial transactions
        INSERT INTO LOG_FINANCIAL_TRANSACTIONS (
            log_id, transaction_type, reference_id, amount_old, amount_new,
            agronomist_id, company_id, username, action
        ) VALUES (
            SEQ_LOG_FINANCIAL.NEXTVAL, 'COMMISSION', :OLD.com_id,
            :OLD.com_amount, :NEW.com_amount, :OLD.com_agronomist_id,
            v_company_id, v_username, v_action
        );
    END IF;
END;
/