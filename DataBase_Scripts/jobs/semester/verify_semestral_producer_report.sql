-- Job programado para ejecutar semestralmente (30 Junio y 31 Diciembre)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SEMESTRAL_PRODUCER_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pcr_generate_semester_producer_report; END;',
        start_date      => TRUNC(SYSDATE, 'YEAR') + INTERVAL '6' MONTH,
        repeat_interval => 'FREQ=YEARLY; BYMONTH=1,7; BYMONTHDAY=1; BYHOUR=10; BYMINUTE=0', 
        enabled         => TRUE,
        comments        => 'Reporte semestral de productores más atendidos - Se envía al gerente'
    );
END;
