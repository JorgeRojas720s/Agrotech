-- Job programado para ejecutar semestralmente (1ro de Enero y Julio)
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'SEMESTRAL_PESTS_DISEASES_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN generate_semester_pests_diseases_report; END;',
        start_date      => TRUNC(SYSDATE, 'YEAR') + INTERVAL '6' MONTH,
        repeat_interval => 'FREQ=YEARLY; BYMONTH=1,7; BYMONTHDAY=1; BYHOUR=11; BYMINUTE=0',
        enabled         => TRUE,
        comments        => 'Reporte semestral de plagas y enfermedades más comunes - Se envía al gerente'
    );
END;
/