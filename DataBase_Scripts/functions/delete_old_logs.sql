-- Crear procedimiento para limpiar logs antiguos (opcional)
CREATE OR REPLACE PROCEDURE PURGE_OLD_LOGS (
    p_retention_days IN NUMBER DEFAULT 365
) AS
BEGIN
    -- Eliminar logs más antiguos que los días de retención especificados
    DELETE FROM LOG_AGRONOMIC_VISITS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_AVAILABILITY_CHANGES 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_FIELD_INSPECTIONS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_LABORATORY_ANALYSIS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_CROP_HISTORY 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_APPLIED_TREATMENTS 
    WHERE application_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_AGRONOMIST_CHANGES 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_SYSTEM_ERRORS 
    WHERE error_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_DATA_MODIFICATIONS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_FINANCIAL_TRANSACTIONS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_ACCOUNT_PAYMENTS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_COMMISSIONS 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_AGRONOMIST_FINANCIAL 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_SPECIALTY_PRICING 
    WHERE change_date < SYSDATE - p_retention_days;
    
    DELETE FROM LOG_SALARY_CHANGES 
    WHERE change_date < SYSDATE - p_retention_days;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Logs antiguos eliminados. Retención: ' || p_retention_days || ' días.');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error purgando logs: ' || SQLERRM);
END;
/