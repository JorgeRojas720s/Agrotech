-- Job programado para ejecutar diariamente el procedimiento check_corrupted_indexes
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'DAILY_CORRUPTED_INDEXES_CHECK',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN check_corrupted_indexes; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=0', 
        enabled         => TRUE,
        comments        => 'Verificación diaria de índices dañados - Notifica al DBA si existen inconsistencias'
    );
    
END;
