-- Trigger for laboratory analysis
CREATE OR REPLACE TRIGGER TRG_LOG_LAB_ANALYSIS
    AFTER INSERT OR UPDATE ON TBL_LABORATORY_ANALYSIS
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
    v_action VARCHAR2(20);
BEGIN
    v_username := USER;
    
    IF INSERTING THEN
        v_action := 'INSERT';
        INSERT INTO LOG_LABORATORY_ANALYSIS (
            log_id, laa_id, laa_technical_files_id,
            results_new, observations_new, analysis_date_new,
            username, action
        ) VALUES (
            SEQ_LOG_LAB_ANALYSIS.NEXTVAL, :NEW.laa_id, 
            :NEW.laa_technical_files_id, :NEW.laa_results,
            :NEW.laa_observations, :NEW.laa_analysis_date,
            v_username, v_action
        );
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        INSERT INTO LOG_LABORATORY_ANALYSIS (
            log_id, laa_id, laa_technical_files_id,
            results_old, results_new,
            observations_old, observations_new,
            analysis_date_old, analysis_date_new,
            username, action
        ) VALUES (
            SEQ_LOG_LAB_ANALYSIS.NEXTVAL, :OLD.laa_id, 
            :OLD.laa_technical_files_id, :OLD.laa_results, :NEW.laa_results,
            :OLD.laa_observations, :NEW.laa_observations,
            :OLD.laa_analysis_date, :NEW.laa_analysis_date,
            v_username, v_action
        );
    END IF;
END;
/