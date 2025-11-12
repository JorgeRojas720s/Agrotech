BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'TS_USAGE_MONITORING_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pcr_check_tablespace_usage; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=8; BYMINUTE=0',  -- Ejecutar diario a las 8:00 AM
        enabled         => TRUE,
        comments        => 'Monitoreo diario de uso de tablespaces'
    );
END;
/