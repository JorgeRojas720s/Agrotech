-- Crear job programado para ejecutar diariamente
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_NOTIFICACION_VISITAS',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pcr_notify_scheduled_visits; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=8; BYMINUTE=0',
        enabled         => TRUE,
        comments        => 'Envía notificaciones de visitas técnicas un día antes'
    );
END;




--!Modificar horario del job si es necesario
BEGIN
    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_NOTIFICACION_VISITAS',
        attribute => 'repeat_interval',
        value     => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=30'
    );
END;
/

--!Probar ejecución del job imediatamente
BEGIN
    DBMS_SCHEDULER.RUN_JOB('JOB_NOTIFICACION_VISITAS');
END;
/


--!Ver historial de ejecuciones del job
SELECT job_name, status, actual_start_date, run_duration, additional_info
FROM user_scheduler_job_run_details
WHERE job_name = 'JOB_NOTIFICACION_VISITAS'
ORDER BY actual_start_date DESC;


--!Ver estado actual del job
SELECT job_name, enabled, state, next_run_date, last_start_date
FROM user_scheduler_jobs
WHERE job_name = 'JOB_NOTIFICACION_VISITAS';