-- Crear job programado para ejecución diaria
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'DAILY_INVALID_OBJECTS_CHECK',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pcr_check_invalid_objects; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0', 
        enabled         => TRUE,
        comments        => 'Verificación diaria de objetos inválidos en la base de datos'
    );
END;
