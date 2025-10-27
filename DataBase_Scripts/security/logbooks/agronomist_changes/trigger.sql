-- Trigger for agronomists
CREATE OR REPLACE TRIGGER TRG_LOG_AGRONOMISTS
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
    
    IF :OLD.agr_company_id != :NEW.agr_company_id OR 
       :OLD.agr_salary_id != :NEW.agr_salary_id THEN
        
        INSERT INTO LOG_AGRONOMIST_CHANGES (
            log_id, agr_id, salary_old, salary_new,
            company_old, company_new, username, action
        ) VALUES (
            SEQ_LOG_AGRONOMISTS.NEXTVAL, :OLD.agr_id,
            v_salary_old, v_salary_new,
            :OLD.agr_company_id, :NEW.agr_company_id,
            v_username, 'UPDATE'
        );
    END IF;
END;
/