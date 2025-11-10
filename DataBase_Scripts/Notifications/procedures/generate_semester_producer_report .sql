CREATE OR REPLACE PROCEDURE generate_semester_producer_report AS
    v_email_recipient VARCHAR2(100);
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_semester VARCHAR2(50);
    v_total_visits NUMBER := 0;
    v_top_producers_count NUMBER := 10; -- Top 10 productores
    v_database_name VARCHAR2(100);
    v_generation_date VARCHAR2(50);
    
    -- Cursor para productores más atendidos (últimos 6 meses)
    CURSOR c_top_producers IS
        SELECT 
            p.per_name || ' ' || p.per_lastname as producer_name,
            f.far_id,
            c.com_name as company_name,
            COUNT(v.vis_id) as total_visits,
            LISTAGG(DISTINCT s.spe_type, ', ') WITHIN GROUP (ORDER BY s.spe_type) as specialities_used
        FROM TBL_VISITS v
        JOIN TBL_PRODUCERS pr ON v.vis_producer_id = pr.pro_id
        JOIN TBL_PERSON p ON pr.pro_person_id = p.per_id
        JOIN TBL_FARMS f ON pr.pro_farm_id = f.far_id
        JOIN TBL_COMPANIES c ON f.far_company_id = c.com_id
        JOIN TBL_AVAILABILITIES av ON v.vis_available_id = av.ava_id
        JOIN TBL_SCHEDULE_SPECIALITIES ss ON av.ava_schedule_specialite_id = ss.scs_id
        JOIN TBL_SPECIALITIES s ON ss.scs_specialite_id = s.spe_id
        WHERE v.vis_attendance = 'S'
          AND v.vis_available_id IN (
              SELECT ava_id FROM TBL_AVAILABILITIES 
              WHERE ava_schedule_agronomist_id IN (
                  SELECT sca_id FROM TBL_SCHEDULE_AGRONOMISTS 
                  WHERE sca_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
              )
              OR ava_schedule_specialite_id IN (
                  SELECT scs_id FROM TBL_SCHEDULE_SPECIALITIES 
                  WHERE scs_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
              )
          )
        GROUP BY p.per_name, p.per_lastname, f.far_id, c.com_name
        ORDER BY total_visits DESC
        FETCH FIRST v_top_producers_count ROWS ONLY;
    
    -- Cursor para estadísticas generales
    CURSOR c_general_stats IS
        SELECT 
            COUNT(DISTINCT v.vis_producer_id) as unique_producers,
            COUNT(v.vis_id) as total_visits,
            ROUND(AVG(v.vis_slots), 2) as avg_slots_per_visit,
            MAX(v.vis_slots) as max_slots_visit,
            COUNT(DISTINCT s.spe_id) as specialities_used
        FROM TBL_VISITS v
        JOIN TBL_AVAILABILITIES av ON v.vis_available_id = av.ava_id
        JOIN TBL_SCHEDULE_SPECIALITIES ss ON av.ava_schedule_specialite_id = ss.scs_id
        JOIN TBL_SPECIALITIES s ON ss.scs_specialite_id = s.spe_id
        WHERE v.vis_attendance = 'S'
          AND v.vis_available_id IN (
              SELECT ava_id FROM TBL_AVAILABILITIES 
              WHERE ava_schedule_agronomist_id IN (
                  SELECT sca_id FROM TBL_SCHEDULE_AGRONOMISTS 
                  WHERE sca_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
              )
              OR ava_schedule_specialite_id IN (
                  SELECT scs_id FROM TBL_SCHEDULE_SPECIALITIES 
                  WHERE scs_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
              )
          );
    
    -- Cursor para especialidades más solicitadas
    CURSOR c_top_specialities IS
        SELECT 
            s.spe_type as speciality_name,
            COUNT(v.vis_id) as total_visits,
            COUNT(DISTINCT v.vis_producer_id) as unique_producers
        FROM TBL_VISITS v
        JOIN TBL_AVAILABILITIES av ON v.vis_available_id = av.ava_id
        JOIN TBL_SCHEDULE_SPECIALITIES ss ON av.ava_schedule_specialite_id = ss.scs_id
        JOIN TBL_SPECIALITIES s ON ss.scs_specialite_id = s.spe_id
        WHERE v.vis_attendance = 'S'
          AND v.vis_available_id IN (
              SELECT ava_id FROM TBL_AVAILABILITIES 
              WHERE ava_schedule_specialite_id IN (
                  SELECT scs_id FROM TBL_SCHEDULE_SPECIALITIES 
                  WHERE scs_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
              )
          )
        GROUP BY s.spe_type
        ORDER BY total_visits DESC
        FETCH FIRST 5 ROWS ONLY;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generando reporte semestral de productores...');
    
    -- Obtener información antes de construir el mensaje
    SELECT name INTO v_database_name FROM v$database;
    v_generation_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
    
    -- Determinar el semestre
    IF EXTRACT(MONTH FROM SYSDATE) <= 6 THEN
        v_semester := 'Enero-Junio ' || EXTRACT(YEAR FROM SYSDATE);
    ELSE
        v_semester := 'Julio-Diciembre ' || EXTRACT(YEAR FROM SYSDATE);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Semestre del reporte: ' || v_semester);
    
 
    v_email_recipient := 'jorgerojas765lt@gmail.com';
   
    -- Construir el reporte
    v_subject := 'Reporte Semestral Productores - ' || v_semester;
    
    v_message := 
        'REPORTE SEMESTRAL DE PRODUCTORES MAS ATENDIDOS' || CHR(10) ||
        '==============================================' || CHR(10) || CHR(10) ||
        
        'INFORMACION GENERAL:' || CHR(10) ||
        '• Periodo: ' || v_semester || CHR(10) ||
        '• Fecha de generacion: ' || v_generation_date || CHR(10) ||
        '• Base de datos: ' || v_database_name || CHR(10) || CHR(10);
    
    -- Sección 1: Estadísticas generales
    FOR rec IN c_general_stats LOOP
        v_message := v_message || 
            'ESTADISTICAS GENERALES:' || CHR(10) ||
            '-----------------------' || CHR(10) ||
            '• Productores unicos atendidos: ' || rec.unique_producers || CHR(10) ||
            '• Total de visitas realizadas: ' || rec.total_visits || CHR(10) ||
            '• Promedio de slots por visita: ' || rec.avg_slots_per_visit || CHR(10) ||
            '• Maximo slots en una visita: ' || rec.max_slots_visit || CHR(10) ||
            '• Especialidades utilizadas: ' || rec.specialities_used || CHR(10) || CHR(10);
        
        v_total_visits := rec.total_visits;
    END LOOP;
    
    -- Sección 2: Top productores más atendidos
    v_message := v_message || 
        'TOP ' || v_top_producers_count || ' PRODUCTORES MAS ATENDIDOS:' || CHR(10) ||
        '-----------------------------------' || CHR(10);
    
    FOR rec IN c_top_producers LOOP
        v_message := v_message ||
            rec.producer_name || CHR(10) ||
            '   Finca ID: ' || rec.far_id || CHR(10) ||
            '   Empresa: ' || rec.company_name || CHR(10) ||
            '   Total visitas: ' || rec.total_visits || CHR(10) ||
            '   Especialidades: ' || rec.specialities_used || CHR(10) ||
            '   Frecuencia: ' || ROUND(rec.total_visits/6, 1) || ' visitas/mes' || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 3: Especialidades más solicitadas
    v_message := v_message || 
        'ESPECIALIDADES MAS SOLICITADAS:' || CHR(10) ||
        '--------------------------------' || CHR(10);
    
    FOR rec IN c_top_specialities LOOP
        v_message := v_message ||
            rec.speciality_name || CHR(10) ||
            '   Total visitas: ' || rec.total_visits || CHR(10) ||
            '   Productores unicos: ' || rec.unique_producers || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 4: Análisis y recomendaciones
    v_message := v_message || 
        'ANALISIS Y RECOMENDACIONES:' || CHR(10) ||
        '---------------------------' || CHR(10);
    
    -- Análisis basado en los datos
    IF v_total_visits > 100 THEN
        v_message := v_message || '• Excelente nivel de actividad en el semestre' || CHR(10);
    ELSIF v_total_visits > 50 THEN
        v_message := v_message || '• Buen nivel de actividad, hay espacio para crecimiento' || CHR(10);
    ELSE
        v_message := v_message || '• Nivel de actividad moderado, considerar estrategias de engagement' || CHR(10);
    END IF;
    
    v_message := v_message || 
        '• Los productores mas frecuentes pueden ser candidatos para programas de fidelizacion' || CHR(10) ||
        '• Considerar ofertas especiales para productores con alta frecuencia de visitas' || CHR(10) ||
        '• Evaluar la distribucion geografica de los productores mas activos' || CHR(10) || CHR(10) ||
        
        'METODOLOGIA:' || CHR(10) ||
        '• Periodo: Ultimos 6 meses' || CHR(10) ||
        '• Solo se consideran visitas con asistencia confirmada' || CHR(10) ||
        '• Incluye todas las especialidades y agronomos' || CHR(10) ||
        '• Ordenado por numero total de visitas' || CHR(10) || CHR(10) ||
        
        '-- Reporte automatico generado por el sistema --';
    
    -- Enviar reporte al gerente
    send_email(
        p_recipient => v_email_recipient,
        p_subject => v_subject,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Reporte semestral enviado a: ' || v_email_recipient);
    DBMS_OUTPUT.PUT_LINE('Total visitas en el periodo: ' || v_total_visits);
    DBMS_OUTPUT.PUT_LINE('Top productores reportados: ' || v_top_producers_count);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generando reporte semestral: ' || SQLERRM);
        
        -- Notificar error al gerente
        BEGIN
            v_subject := 'Error en Reporte Semestral - ' || v_semester;
            v_message := 
                'Error generando el reporte semestral de productores:' || CHR(10) || CHR(10) ||
                'Error: ' || SQLERRM || CHR(10) ||
                'Fecha: ' || v_generation_date || CHR(10) ||
                'Por favor, contacte al administrador del sistema.';
                
            send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
END generate_semester_producer_report;
/