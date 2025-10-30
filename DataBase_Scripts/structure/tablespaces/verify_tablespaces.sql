CREATE OR REPLACE PROCEDURE check_tablespace_usage AS
    v_percentage NUMBER;
    v_total_mb NUMBER;
    v_free_mb NUMBER;
    v_alert_message VARCHAR2(4000);
    v_count_alerts NUMBER := 0;
    
    CURSOR c_tablespaces IS
        SELECT tablespace_name,
               ROUND((1 - (NVL(free_space,0) / total_space)) * 100, 2) as used_percentage,
               ROUND(total_space/1024/1024, 2) as total_mb,
               ROUND(free_space/1024/1024, 2) as free_mb
        FROM (
            SELECT a.tablespace_name,
                   a.bytes_alloc total_space,
                   NVL(b.bytes_free, 0) free_space
            FROM (
                SELECT tablespace_name, SUM(bytes) bytes_alloc
                FROM dba_data_files
                GROUP BY tablespace_name
            ) a,
            (
                SELECT tablespace_name, SUM(bytes) bytes_free
                FROM dba_free_space
                GROUP BY tablespace_name
            ) b
            WHERE a.tablespace_name = b.tablespace_name(+)
        );
BEGIN
    -- Limpiar logs antiguos (mantener solo 30 días)
    DELETE FROM TS_MONITORING_LOGS WHERE check_date < SYSDATE - 30;
    COMMIT;
    
    FOR ts_rec IN c_tablespaces LOOP
        -- Insertar en log
        INSERT INTO TS_MONITORING_LOGS (log_id, tablespace_name, used_percentage, total_mb, free_mb)
        VALUES (ts_monitoring_seq.NEXTVAL, ts_rec.tablespace_name, ts_rec.used_percentage, ts_rec.total_mb, ts_rec.free_mb);
        
        -- Verificar si supera 85%
        IF ts_rec.used_percentage > 85 THEN
            v_count_alerts := v_count_alerts + 1;
            
            -- Construir mensaje de alerta
            IF v_alert_message IS NULL THEN
                v_alert_message := 'ALERTA: Tablespaces con uso superior al 85%:' || CHR(10) || CHR(10);
            END IF;
            
            v_alert_message := v_alert_message || 
                              '- Tablespace: ' || ts_rec.tablespace_name || CHR(10) ||
                              '  Uso: ' || ts_rec.used_percentage || '%' || CHR(10) ||
                              '  Total: ' || ts_rec.total_mb || ' MB' || CHR(10) ||
                              '  Libre: ' || ts_rec.free_mb || ' MB' || CHR(10) || CHR(10);
            
            -- Marcar alerta como enviada
            UPDATE TS_MONITORING_LOGS 
            SET alert_sent = 'Y' 
            WHERE log_id = ts_monitoring_seq.CURRVAL;
        END IF;
    END LOOP;
    
    COMMIT;
    
    -- Enviar correo si hay alertas
    IF v_count_alerts > 0 THEN
        send_email(
            p_recipient => 'jorge.rojas.mena@est.una.ac.cr', 
            p_subject => 'tablespace usage alert',
            p_message => v_alert_message
        );
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO TS_MONITORING_LOGS (log_id, tablespace_name, used_percentage, alert_sent)
        VALUES (ts_monitoring_seq.NEXTVAL, 'ERROR', 0, 'Y');
        COMMIT;
        -- También enviar correo de error
        send_email(
            p_recipient => 'jorge.rojas.mena@est.una.ac.cr', 
            p_subject => 'tablespace usage error',
            p_message => sqlerrm
        );
END check_tablespace_usage;
/