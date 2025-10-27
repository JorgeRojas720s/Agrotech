-- Trigger for treatments
CREATE OR REPLACE TRIGGER TRG_LOG_TREATMENTS
    AFTER INSERT ON TBL_TEF_X_TRE
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_treatment_name VARCHAR2(50);
    v_treatment_type VARCHAR2(45);
BEGIN
    v_username := USER;
    
    -- Get treatment details
    SELECT tre.tre_name, trt.trt_name
    INTO v_treatment_name, v_treatment_type
    FROM TBL_TREATMENTS tre
    JOIN TBL_TREATMENTS_TYPE trt ON tre.tre_treatment_type_id = trt.trt_id
    WHERE tre.tre_id = :NEW.txt_treatments_id;
    
    INSERT INTO LOG_APPLIED_TREATMENTS (
        log_id, txt_technical_file_id, txt_treatments_id,
        treatment_name, treatment_type, username, action
    ) VALUES (
        SEQ_LOG_TREATMENTS.NEXTVAL, :NEW.txt_technical_file_id, 
        :NEW.txt_treatments_id, v_treatment_name, v_treatment_type,
        v_username, 'INSERT'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Handle exception silently
END;
/