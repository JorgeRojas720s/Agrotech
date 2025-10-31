-- Trigger for agronomist financial changes
CREATE OR REPLACE TRIGGER TRG_LOG_AGRONOMIST_FINANCIAL
    AFTER UPDATE ON TBL_AGRONOMISTS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_salary_old NUMBER(15,2);
    v_salary_new NUMBER(15,2);
BEGIN
    v_username := USER;
    
    -- Get salary amounts
    BEGIN
        SELECT sal_amount INTO v_salary_old
        FROM TBL_SALARIES WHERE sal_id = :OLD.agr_salary_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_salary_old := NULL;
    END;
    
    BEGIN
        SELECT sal_amount INTO v_salary_new
        FROM TBL_SALARIES WHERE sal_id = :NEW.agr_salary_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_salary_new := NULL;
    END;
    
    IF :OLD.agr_consult_price != :NEW.agr_consult_price OR 
       :OLD.agr_salary_id != :NEW.agr_salary_id THEN
        
        INSERT INTO LOG_AGRONOMIST_FINANCIAL (
            log_id, agr_id, consult_price_old, consult_price_new,
            salary_id_old, salary_id_new, salary_amount_old, salary_amount_new,
            username, action
        ) VALUES (
            SEQ_LOG_AGRO_FINANCIAL.NEXTVAL, :OLD.agr_id,
            :OLD.agr_consult_price, :NEW.agr_consult_price,
            :OLD.agr_salary_id, :NEW.agr_salary_id,
            v_salary_old, v_salary_new, v_username, 'UPDATE'
        );
        
        -- Log salary changes in general financial transactions
        IF :OLD.agr_salary_id != :NEW.agr_salary_id THEN
            INSERT INTO LOG_FINANCIAL_TRANSACTIONS (
                log_id, transaction_type, reference_id, amount_old, amount_new,
                agronomist_id, username, action
            ) VALUES (
                SEQ_LOG_FINANCIAL.NEXTVAL, 'SALARY_CHANGE', :OLD.agr_id,
                v_salary_old, v_salary_new, :OLD.agr_id, v_username, 'UPDATE'
            );
        END IF;
    END IF;
END;
/