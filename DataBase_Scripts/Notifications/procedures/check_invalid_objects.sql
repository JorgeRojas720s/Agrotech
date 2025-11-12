CREATE OR REPLACE PROCEDURE pcr_check_invalid_objects AS
    v_invalid_count NUMBER;
    v_email_recipient VARCHAR2(100);
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_invalid_details CLOB;
    v_db_name VARCHAR2(100);
    v_instance_name VARCHAR2(100);
    
    CURSOR c_invalid_objects IS
        SELECT owner, object_name, object_type, status, created, last_ddl_time
        FROM all_objects
        WHERE status = 'INVALID'
        ORDER BY owner, object_type, object_name;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando verificación de objetos inválidos...');
    DBMS_OUTPUT.PUT_LINE('Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    
    -- Contar objetos inválidos
    SELECT COUNT(*)
    INTO v_invalid_count
    FROM all_objects
    WHERE status = 'INVALID';
    
    DBMS_OUTPUT.PUT_LINE('Total de objetos inválidos encontrados: ' || v_invalid_count);


    v_email_recipient := 'jorgerojas765lt@gmail.com'; -- Email por defecto


    -- Si hay objetos inválidos, preparar notificación
    IF v_invalid_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Se encontraron objetos inválidos. Preparando notificación...');
        
        -- Construir detalles de objetos inválidos
        v_invalid_details := 'DETALLE DE OBJETOS INVÁLIDOS:' || CHR(10) || CHR(10);
        v_invalid_details := v_invalid_details || 
            RPAD('OWNER', 20) || ' | ' ||
            RPAD('TIPO', 15) || ' | ' ||
            RPAD('NOMBRE', 30) || ' | ' ||
            RPAD('CREADO', 12) || ' | ' ||
            RPAD('ÚLTIMO DDL', 12) || CHR(10);
        v_invalid_details := v_invalid_details || 
            RPAD('-', 20, '-') || '-+-' ||
            RPAD('-', 15, '-') || '-+-' ||
            RPAD('-', 30, '-') || '-+-' ||
            RPAD('-', 12, '-') || '-+-' ||
            RPAD('-', 12, '-') || CHR(10);
            
        FOR rec IN c_invalid_objects LOOP
            v_invalid_details := v_invalid_details ||
                RPAD(rec.owner, 20) || ' | ' ||
                RPAD(rec.object_type, 15) || ' | ' ||
                RPAD(rec.object_name, 30) || ' | ' ||
                RPAD(TO_CHAR(rec.created, 'DD/MM/YYYY'), 12) || ' | ' ||
                RPAD(TO_CHAR(rec.last_ddl_time, 'DD/MM/YYYY'), 12) || CHR(10);
        END LOOP;
        
        -- Construir mensaje del email
        v_subject := 'ALERTA: ' || v_invalid_count || ' Objetos Inválidos en BD - ' || 
                    TO_CHAR(SYSDATE, 'DD/MM/YYYY');
        
        SELECT name INTO v_db_name FROM v$database;
        SELECT instance_name INTO v_instance_name FROM v$instance;

        -- Construir el mensaje
        v_message :=
            'ALERTA DEL SISTEMA DE MONITOREO DE BASE DE DATOS' || CHR(10) ||
            '==================================================' || CHR(10) || CHR(10) ||

            'Se han detectado ' || v_invalid_count || ' objetos inválidos en la base de datos.' || CHR(10) || CHR(10) ||

            'INFORMACION GENERAL:' || CHR(10) ||
            '   • Base de Datos: ' || v_db_name || CHR(10) ||
            '   • Instancia: ' || v_instance_name || CHR(10) ||
            '   • Fecha de verificación: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || CHR(10) ||
            '   • Total de objetos inválidos: ' || v_invalid_count || CHR(10) || CHR(10) ||

            v_invalid_details || CHR(10) ||

            'ACCIONES RECOMENDADAS:' || CHR(10) ||
            '   1. Recompilar objetos inválidos manualmente' || CHR(10) ||
            '   2. Verificar logs de aplicación' || CHR(10) ||
            '   3. Revisar cambios recientes en el esquema' || CHR(10) ||
            '   4. Validar dependencias entre objetos' || CHR(10) || CHR(10) ||

            'COMANDOS UTILES:' || CHR(10) ||
            '   -- Recompilar todos los objetos inválidos' || CHR(10) ||
            '   EXEC UTL_RECOMP.RECOMP_SERIAL(''SCHEMA_NAME'');' || CHR(10) ||
            '   -- O usar DBMS_UTILITY.COMPILE_SCHEMA' || CHR(10) ||
            '   EXEC DBMS_UTILITY.COMPILE_SCHEMA(''SCHEMA_NAME'');' || CHR(10) || CHR(10) ||

            'Este es un mensaje automático del sistema de monitoreo.' || CHR(10) ||
            'Por favor, no responder este correo.';
        
        -- Enviar notificación al DBA
        pcr_send_email(
            p_recipient => v_email_recipient,
            p_subject => v_subject,
            p_message => v_message
        );
        
        DBMS_OUTPUT.PUT_LINE('Notificación enviada al DBA: ' || v_email_recipient);
        
        -- Registrar en log del sistema
        INSERT INTO SYSTEM_AUDIT (
            audit_id, audit_type, audit_message, audit_date, audit_user
        ) VALUES (
            seq_system_audit.NEXTVAL, 'INVALID_OBJECTS', 
            'Se encontraron ' || v_invalid_count || ' objetos inválidos. Notificación enviada.',
            SYSTIMESTAMP, 'SYSTEM'
        );
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron objetos inválidos.');
        
        -- Opcional: Enviar notificación de "todo bien" (comentar si no se desea)
        IF TO_CHAR(SYSDATE, 'D') = '1' THEN -- Solo los domingos
            v_subject := 'Estado de Base de Datos - ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY');
            SELECT name INTO v_db_name FROM v$database;
            SELECT instance_name INTO v_instance_name FROM v$instance;

            -- Construir el mensaje
            v_message :=
                'REPORTE DE ESTADO DE BASE DE DATOS' || CHR(10) ||
                '===================================' || CHR(10) || CHR(10) ||
                'Todos los objetos de la base de datos están válidos.' || CHR(10) || CHR(10) ||
                'INFORMACION DEL SISTEMA:' || CHR(10) ||
                '   • Base de Datos: ' || v_db_name || CHR(10) ||
                '   • Instancia: ' || v_instance_name || CHR(10) ||
                '   • Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || CHR(10) ||
                '   • Objetos inválidos: 0' || CHR(10) || CHR(10) ||
                'Estado del sistema: NORMAL';
                
            pcr_send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
            
            DBMS_OUTPUT.PUT_LINE('Reporte de estado normal enviado al DBA.');
        END IF;
    END IF;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Verificación de objetos inválidos completada.');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en verificación de objetos inválidos: ' || SQLERRM);
        
        -- Intentar notificar el error al DBA
        BEGIN
            v_subject := 'ERROR en Verificación de Objetos Inválidos';
            v_message := 
                'ERROR EN SISTEMA DE MONITOREO' || CHR(10) ||
                '==============================' || CHR(10) || CHR(10) ||
                'Se produjo un error durante la verificación de objetos inválidos:' || CHR(10) || CHR(10) ||
                'Error: ' || SQLERRM || CHR(10) ||
                'Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS');
                
            pcr_send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Si falla el email, al menos registrar en output
        END;
        
        RAISE;
END pcr_check_invalid_objects;
