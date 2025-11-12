CREATE OR REPLACE PROCEDURE pcr_notify_scheduled_visits AS
    CURSOR c_visitas IS
        SELECT 
            v.vis_id,
            p.per_name || ' ' || p.per_lastname AS nombre_productor,
            pc.con_contact AS email_productor,
            agr_per.per_name || ' ' || agr_per.per_lastname AS nombre_agronomo,
            sca.sca_date AS fecha_visita,
            sca.sca_start_time AS hora_inicio,
            sca.sca_end_time AS hora_fin,
            f.far_id,
            c.com_name AS empresa_agronomo
        FROM TBL_VISITS v
        JOIN TBL_PRODUCERS pr ON v.vis_producer_id = pr.pro_id
        JOIN TBL_PERSON p ON pr.pro_person_id = p.per_id
        JOIN TBL_PER_X_CON pxc ON p.per_id = pxc.pxc_person_id
        JOIN TBL_CONTACTS pc ON pxc.pxc_contact_id = pc.con_id
        JOIN TBL_AVAILABILITIES av ON v.vis_available_id = av.ava_id
        JOIN TBL_SCHEDULE_AGRONOMISTS sca ON av.ava_schedule_agronomist_id = sca.sca_id
        JOIN TBL_AGRONOMISTS a ON sca.sca_agronomist_id = a.agr_id
        JOIN TBL_PERSON agr_per ON a.agr_person_id = agr_per.per_id
        JOIN TBL_COMPANIES c ON a.agr_company_id = c.com_id
        JOIN TBL_FARMS f ON pr.pro_farm_id = f.far_id
        WHERE pc.con_type = 'EMAIL'
          AND sca.sca_date = TRUNC(SYSDATE) + 1  -- Visitas de mañana
          AND v.vis_attendance IS NULL;  -- Visitas no confirmadas aún

    v_subject VARCHAR2(200);
    v_message VARCHAR2(4000);
    v_contador NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('🔍 Buscando visitas programadas para mañana...');
    
    FOR visita IN c_visitas LOOP
        BEGIN
            -- Construir asunto del correo
            v_subject := 'Recordatorio: Visita Técnica Programada - ' || 
                        TO_CHAR(visita.fecha_visita, 'DD/MM/YYYY');
            
            -- Construir mensaje del correo
            v_message := 
                'Estimado/a ' || visita.nombre_productor || ',' || CHR(10) || CHR(10) ||
                'Le recordamos que tiene programada una visita técnica para mañana:' || CHR(10) || CHR(10) ||
                '📅 Fecha: ' || TO_CHAR(visita.fecha_visita, 'DD/MM/YYYY') || CHR(10) ||
                '⏰ Hora: ' || visita.hora_inicio || ':00 - ' || visita.hora_fin || ':00' || CHR(10) ||
                '👨‍🌾 Agrónomo: ' || visita.nombre_agronomo || CHR(10) ||
                '🏢 Empresa: ' || visita.empresa_agronomo || CHR(10) ||
                '📍 Finca ID: ' || visita.far_id || CHR(10) || CHR(10) ||
                'Por favor, asegúrese de estar disponible en la fecha y hora indicadas.' || CHR(10) || CHR(10) ||
                'Si necesita reprogramar la visita, por favor contacte a su agrónomo asignado.' || CHR(10) || CHR(10) ||
                'Saludos cordiales,' || CHR(10) ||
                'Sistema de Gestión Agrícola' || CHR(10) ||
                visita.empresa_agronomo;
            
            -- Enviar correo
            pcr_send_email(
                p_recipient => visita.email_productor,
                p_subject => v_subject,
                p_message => v_message
            );
            
            v_contador := v_contador + 1;
            DBMS_OUTPUT.PUT_LINE('✅ Notificación enviada a: ' || visita.email_productor);
            
            -- Pequeña pausa para no saturar el servidor SMTP
            DBMS_LOCK.SLEEP(2);
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('❌ Error enviando a ' || visita.email_productor || ': ' || SQLERRM);
        END;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('📧 Proceso completado. Total de notificaciones enviadas: ' || v_contador);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error en el proceso de notificación: ' || SQLERRM);
        RAISE;
END pcr_notify_scheduled_visits;
/