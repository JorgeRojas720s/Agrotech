-- Trigger for account payments
CREATE OR REPLACE TRIGGER TRG_LOG_ACCOUNT_PAYMENTS
    AFTER INSERT OR UPDATE ON TBL_ACCOUNT
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
BEGIN
    v_username := USER;
    
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_ACCOUNT_PAYMENTS (
            log_id, acc_id, amount_new, status_new, person_id,
            username, action
        ) VALUES (
            SEQ_LOG_ACCOUNTS.NEXTVAL, :NEW.acc_id, :NEW.acc_amount,
            :NEW.acc_state, :NEW.acc_person_id, v_username, v_action
        );
        
        -- Also log in general financial transactions
        INSERT INTO LOG_FINANCIAL_TRANSACTIONS (
            log_id, transaction_type, reference_id, amount_new,
            status_new, person_id, username, action
        ) VALUES (
            SEQ_LOG_FINANCIAL.NEXTVAL, 'ACCOUNT_PAYMENT', :NEW.acc_id,
            :NEW.acc_amount, :NEW.acc_state, :NEW.acc_person_id,
            v_username, v_action
        );
        
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_ACCOUNT_PAYMENTS (
            log_id, acc_id, amount_old, amount_new,
            status_old, status_new, person_id,
            username, action
        ) VALUES (
            SEQ_LOG_ACCOUNTS.NEXTVAL, :OLD.acc_id, :OLD.acc_amount, :NEW.acc_amount,
            :OLD.acc_state, :NEW.acc_state, :OLD.acc_person_id,
            v_username, v_action
        );
        
        -- Also log in general financial transactions
        INSERT INTO LOG_FINANCIAL_TRANSACTIONS (
            log_id, transaction_type, reference_id, amount_old, amount_new,
            status_old, status_new, person_id, username, action
        ) VALUES (
            SEQ_LOG_FINANCIAL.NEXTVAL, 'ACCOUNT_PAYMENT', :OLD.acc_id,
            :OLD.acc_amount, :NEW.acc_amount, :OLD.acc_state, :NEW.acc_state,
            :OLD.acc_person_id, v_username, v_action
        );
    END IF;
END;
/