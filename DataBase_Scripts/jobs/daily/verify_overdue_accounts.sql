-- Crear job programado (ejecutar como SYS o con permisos)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'AUTO_OVERDUE_ACCOUNTS_NOTIFICATION',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN notify_overdue_accounts; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=8; BYMINUTE=0',
        enabled         => TRUE,
        comments        => 'Notificación automática de cuentas pendientes mayores a 1 mes'
    );
END;
