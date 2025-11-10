CREATE OR REPLACE PROCEDURE check_corrupted_indexes AS
    v_corrupted_count NUMBER;
    v_email_recipient VARCHAR2(100);
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_database_name VARCHAR2(100);
    v_current_date VARCHAR2(50);
    
    CURSOR c_corrupted_indexes IS
        SELECT 
            i.owner,
            i.index_name,
            i.table_name,
            i.status,
            s.blocks,
            s.bytes
        FROM all_indexes i
        JOIN dba_segments s ON i.index_name = s.segment_name AND i.owner = s.owner
        WHERE i.status NOT IN ('VALID', 'N/A')
           OR EXISTS (
               SELECT 1 
               FROM dba_objects o 
               WHERE o.owner = i.owner 
                 AND o.object_name = i.index_name 
                 AND o.status = 'INVALID'
           );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificando índices dañados...');
    
    -- Obtener información de la base de datos por separado
    SELECT name INTO v_database_name FROM v$database;
    v_current_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
    
    -- Contar índices con problemas
    SELECT COUNT(*)
    INTO v_corrupted_count
    FROM all_indexes i
    WHERE i.status NOT IN ('VALID', 'N/A')
       OR EXISTS (
           SELECT 1 
           FROM dba_objects o 
           WHERE o.owner = i.owner 
             AND o.object_name = i.index_name 
             AND o.status = 'INVALID'
       );
    
    DBMS_OUTPUT.PUT_LINE('Índices con problemas: ' || v_corrupted_count);
    
    v_email_recipient := 'jorgerojas765lt@gmail.com';
    
    -- Si hay índices dañados, enviar notificación
    IF v_corrupted_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Enviando notificación al DBA...');
        
        -- Construir mensaje SIN SELECTs embebidos
        v_subject := v_corrupted_count || ' Índices Dañados - ' || 
                    TO_CHAR(SYSDATE, 'DD/MM/YY');
        
        v_message := 
            'ALERTA: ' || v_corrupted_count || ' índices con problemas detectados.' || CHR(10) || CHR(10) ||
            
            'BASE DE DATOS: ' || v_database_name || CHR(10) ||
            'FECHA: ' || v_current_date || CHR(10) || CHR(10) ||
            
            'ÍNDICES CON PROBLEMAS:' || CHR(10);
        
        -- Agregar detalles de índices dañados
        FOR rec IN c_corrupted_indexes LOOP
            IF LENGTH(v_message) < 1500 THEN
                v_message := v_message || 
                    '• ' || rec.owner || '.' || rec.index_name || CHR(10) ||
                    '  Tabla: ' || rec.table_name || CHR(10) ||
                    '  Estado: ' || rec.status || CHR(10) ||
                    '  Tamaño: ' || ROUND(rec.bytes/1024/1024, 2) || ' MB' || CHR(10) ||
                    '  Bloques: ' || rec.blocks || CHR(10) ||
                    '----------------------------------------' || CHR(10);
            END IF;
        END LOOP;
        
        v_message := v_message || CHR(10) ||
            'ACCIONES RECOMENDADAS:' || CHR(10) ||
            '1. Reconstruir índices dañados' || CHR(10) ||
            '2. Verificar espacio en tablespace' || CHR(10) ||
            '3. Revisar logs de alerta' || CHR(10) || CHR(10) ||
            
            'EJEMPLO DE RECONSTRUCCIÓN:' || CHR(10) ||
            'ALTER INDEX nombre_esquema.nombre_indice REBUILD;' || CHR(10) || CHR(10) ||
            
            '-- Mensaje automático --';
        
        -- Enviar notificación
        send_email(
            p_recipient => v_email_recipient,
            p_subject => v_subject,
            p_message => v_message
        );
        
        DBMS_OUTPUT.PUT_LINE('Notificación enviada a: ' || v_email_recipient);
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('No hay índices dañados.');
        
        -- Notificación de estado normal solo los miércoles
        IF TO_CHAR(SYSDATE, 'D') = '4' THEN -- Miércoles
            v_subject := 'Índices OK - ' || TO_CHAR(SYSDATE, 'DD/MM/YY');
            v_message := 
                'Estado de índices: NORMAL' || CHR(10) ||
                'Índices dañados: 0' || CHR(10) ||
                'BD: ' || v_database_name || CHR(10) ||
                'Fecha: ' || v_current_date || CHR(10) ||
                '-- Mensaje automático --';
                
            send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        END IF;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        
        -- Notificación de error
        BEGIN
            v_subject := 'Error verificación índices';
            v_message := 
                'Error en verificación de índices: ' || SQLERRM || CHR(10) ||
                'Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YY HH24:MI') || CHR(10) ||
                '-- Mensaje automático --';
                
            send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
END check_corrupted_indexes;
/