-- Job programado para ejecutar el último día de cada mes
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'MONTHLY_INCOME_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN pcr_generate_monthly_income_report; END;',
        start_date      => TRUNC(LAST_DAY(SYSDATE)) + 1,
        repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=9; BYMINUTE=0',
        enabled         => TRUE,
        comments        => 'Reporte mensual de ingresos por agrónomo y especialidad - Se envía al gerente'
    );
END;
/