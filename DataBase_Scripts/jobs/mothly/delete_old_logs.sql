-- Programar job de limpieza automática (ejecutar mensualmente)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'PURGE_OLD_LOGS_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN PURGE_OLD_LOGS(365); END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=2; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => 'Limpieza mensual de logs antiguos'
    );
END;
/