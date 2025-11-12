CREATE OR REPLACE PROCEDURE pcr_generate_monthly_income_report AS
    v_email_recipient VARCHAR2(100);
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_month_year VARCHAR2(50);
    v_total_income NUMBER := 0;
    v_database_name VARCHAR2(100);
    v_agronomist_count NUMBER := 0;
    v_speciality_count NUMBER := 0;
    v_generation_date VARCHAR2(50);
    
    -- Cursor para ingresos por agrónomo
    CURSOR c_agronomist_income IS
        SELECT 
            p.per_name || ' ' || p.per_lastname as agronomist_name,
            c.com_name as company_name,
            SUM(v.vis_slots * a.agr_consult_price) as total_income,
            COUNT(v.vis_id) as total_visits
        FROM TBL_VISITS v
        JOIN TBL_PRODUCERS pr ON v.vis_producer_id = pr.pro_id
        JOIN TBL_AGRONOMISTS a ON v.vis_available_id IN (
            SELECT ava_id FROM TBL_AVAILABILITIES 
            WHERE ava_schedule_agronomist_id IN (
                SELECT sca_id FROM TBL_SCHEDULE_AGRONOMISTS 
                WHERE sca_agronomist_id = a.agr_id
            )
        )
        JOIN TBL_PERSON p ON a.agr_person_id = p.per_id
        JOIN TBL_COMPANIES c ON a.agr_company_id = c.com_id
        WHERE v.vis_attendance = 'S'
          AND TRUNC(v.vis_available_id) -- Necesitamos ajustar esta condición para obtener la fecha real
          BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MONTH') 
          AND TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE, -1)))
        GROUP BY p.per_name, p.per_lastname, c.com_name
        ORDER BY total_income DESC;
    
    -- Cursor para ingresos por especialidad
    CURSOR c_speciality_income IS
        SELECT 
            s.spe_type as speciality_name,
            SUM(v.vis_slots * s.spe_price) as total_income,
            COUNT(v.vis_id) as total_visits
        FROM TBL_VISITS v
        JOIN TBL_AVAILABILITIES av ON v.vis_available_id = av.ava_id
        JOIN TBL_SCHEDULE_SPECIALITIES ss ON av.ava_schedule_specialite_id = ss.scs_id
        JOIN TBL_SPECIALITIES s ON ss.scs_specialite_id = s.spe_id
        WHERE v.vis_attendance = 'S'
          AND TRUNC(ss.scs_date) 
          BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MONTH') 
          AND TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE, -1)))
        GROUP BY s.spe_type
        ORDER BY total_income DESC;
        
    -- Cursor para comisiones pagadas
    CURSOR c_commissions_paid IS
        SELECT 
            p.per_name || ' ' || p.per_lastname as agronomist_name,
            SUM(cm.com_amount) as total_commissions,
            COUNT(cm.com_id) as commission_count
        FROM TBL_COMISSIONS cm
        JOIN TBL_AGRONOMISTS a ON cm.com_agronomist_id = a.agr_id
        JOIN TBL_PERSON p ON a.agr_person_id = p.per_id
        WHERE TRUNC(cm.com_date) 
          BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -1), 'MONTH') 
          AND TRUNC(LAST_DAY(ADD_MONTHS(SYSDATE, -1)))
        GROUP BY p.per_name, p.per_lastname
        ORDER BY total_commissions DESC;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generando reporte mensual de ingresos...');
    
    -- Obtener información antes de construir el mensaje
    SELECT name INTO v_database_name FROM v$database;
    v_month_year := TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'Month YYYY');
    v_generation_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
    
    -- Contar agrónomos y especialidades
    SELECT COUNT(*) INTO v_agronomist_count FROM c_agronomist_income;
    SELECT COUNT(*) INTO v_speciality_count FROM c_speciality_income;
    
    DBMS_OUTPUT.PUT_LINE('Mes del reporte: ' || v_month_year);
    

    v_email_recipient := 'jorgerojas765lt@gmail.com'; -- Email por defecto
  
    -- Construir el reporte
    v_subject := 'Reporte Mensual de Ingresos - ' || v_month_year;
    
    v_message := 
        'REPORTE MENSUAL DE INGRESOS - ' || UPPER(v_month_year) || CHR(10) ||
        '============================================' || CHR(10) || CHR(10) ||
        
        'INFORMACION GENERAL:' || CHR(10) ||
        '• Periodo: ' || v_month_year || CHR(10) ||
        '• Fecha de generacion: ' || v_generation_date || CHR(10) ||
        '• Base de datos: ' || v_database_name || CHR(10) || CHR(10);
    
    -- Sección 1: Ingresos por agrónomo
    v_message := v_message || 
        'INGRESOS POR AGRONOMO:' || CHR(10) ||
        '---------------------' || CHR(10);
    
    FOR rec IN c_agronomist_income LOOP
        v_message := v_message ||
            rec.agronomist_name || CHR(10) ||
            '   Empresa: ' || rec.company_name || CHR(10) ||
            '   Ingresos: ₡' || TO_CHAR(rec.total_income, '999,999,999.00') || CHR(10) ||
            '   Visitas: ' || rec.total_visits || CHR(10) ||
            '   Promedio por visita: ₡' || 
                CASE WHEN rec.total_visits > 0 
                     THEN TO_CHAR(rec.total_income/rec.total_visits, '999,999.00')
                     ELSE '0.00' END || CHR(10) ||
            '---' || CHR(10);
        
        v_total_income := v_total_income + rec.total_income;
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 2: Ingresos por especialidad
    v_message := v_message || 
        'INGRESOS POR ESPECIALIDAD:' || CHR(10) ||
        '-------------------------' || CHR(10);
    
    FOR rec IN c_speciality_income LOOP
        v_message := v_message ||
            rec.speciality_name || CHR(10) ||
            '   Ingresos: ₡' || TO_CHAR(rec.total_income, '999,999,999.00') || CHR(10) ||
            '   Consultas: ' || rec.total_visits || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 3: Comisiones pagadas
    v_message := v_message || 
        'COMISIONES PAGADAS:' || CHR(10) ||
        '------------------' || CHR(10);
    
    FOR rec IN c_commissions_paid LOOP
        v_message := v_message ||
            rec.agronomist_name || CHR(10) ||
            '   Comisiones: ₡' || TO_CHAR(rec.total_commissions, '999,999,999.00') || CHR(10) ||
            '   Pagos: ' || rec.commission_count || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Resumen general
    v_message := v_message || 
        'RESUMEN GENERAL:' || CHR(10) ||
        '---------------' || CHR(10) ||
        'Ingreso total: ₡' || TO_CHAR(v_total_income, '999,999,999.00') || CHR(10) ||
        'Total agronomos: ' || v_agronomist_count || CHR(10) ||
        'Total especialidades: ' || v_speciality_count || CHR(10) || CHR(10) ||
        
        'ANALISIS:' || CHR(10) ||
        '• Este reporte incluye solo visitas con asistencia confirmada' || CHR(10) ||
        '• Los ingresos se calculan basados en tarifas de consulta' || CHR(10) ||
        '• Las comisiones reflejan pagos efectuados en el periodo' || CHR(10) || CHR(10) ||
        
        '-- Reporte automatico generado por el sistema --';
    
    -- Enviar reporte al gerente
    pcr_send_email(
        p_recipient => v_email_recipient,
        p_subject => v_subject,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Reporte mensual enviado a: ' || v_email_recipient);
    DBMS_OUTPUT.PUT_LINE('Ingreso total reportado: ₡' || TO_CHAR(v_total_income, '999,999,999.00'));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generando reporte: ' || SQLERRM);
        
        -- Notificar error al gerente
        BEGIN
            v_subject := 'Error en Reporte Mensual - ' || v_month_year;
            v_message := 
                'Error generando el reporte mensual de ingresos:' || CHR(10) || CHR(10) ||
                'Error: ' || SQLERRM || CHR(10) ||
                'Fecha: ' || v_generation_date || CHR(10) ||
                'Por favor, contacte al administrador del sistema.';
                
            pcr_send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
END pcr_generate_monthly_income_report;
/