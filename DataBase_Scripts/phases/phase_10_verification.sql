PROMPT 
PROMPT ==================== FASE 10: VERIFICACIÓN FINAL ====================

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== VERIFICANDO OBJETOS CREADOS ===');
    
    -- Contadores
    DECLARE
        v_table_count NUMBER := 0;
        v_function_count NUMBER := 0;
        v_trigger_count NUMBER := 0;
        v_procedure_count NUMBER := 0;
        v_job_count NUMBER := 0;
    BEGIN
        -- Verificar tablas
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- TABLAS ---');
        FOR t IN (SELECT table_name, num_rows 
                  FROM user_tables 
                  WHERE table_name LIKE 'TBL_%'
                  ORDER BY table_name) 
        LOOP
            DBMS_OUTPUT.PUT_LINE('✅ Tabla: ' || t.table_name || 
                                CASE WHEN t.num_rows IS NOT NULL THEN 
                                    ' (' || t.num_rows || ' filas)' 
                                ELSE '' END);
            v_table_count := v_table_count + 1;
        END LOOP;
        
        -- Verificar funciones
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- FUNCIONES ---');
        FOR f IN (SELECT object_name, status
                  FROM user_objects 
                  WHERE object_type = 'FUNCTION'
                  ORDER BY object_name) 
        LOOP
            DBMS_OUTPUT.PUT_LINE('✅ Función: ' || f.object_name || 
                                ' [' || f.status || ']');
            v_function_count := v_function_count + 1;
        END LOOP;
        
        -- Verificar procedimientos
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- PROCEDIMIENTOS ---');
        FOR p IN (SELECT object_name, status
                  FROM user_objects 
                  WHERE object_type = 'PROCEDURE'
                  ORDER BY object_name) 
        LOOP
            DBMS_OUTPUT.PUT_LINE('✅ Procedimiento: ' || p.object_name || 
                                ' [' || p.status || ']');
            v_procedure_count := v_procedure_count + 1;
        END LOOP;
        
        -- Verificar triggers
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- TRIGGERS ---');
        FOR trg IN (SELECT trigger_name, status
                    FROM user_triggers 
                    WHERE trigger_name LIKE 'TRG_%'
                    ORDER BY trigger_name) 
        LOOP
            DBMS_OUTPUT.PUT_LINE('✅ Trigger: ' || trg.trigger_name || 
                                ' [' || trg.status || ']');
            v_trigger_count := v_trigger_count + 1;
        END LOOP;
        
        -- Verificar jobs (aproximado)
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- JOBS ---');
        BEGIN
            FOR j IN (SELECT job_name, enabled 
                      FROM user_scheduler_jobs 
                      ORDER BY job_name) 
            LOOP
                DBMS_OUTPUT.PUT_LINE('✅ Job: ' || j.job_name || 
                                    ' [' || j.enabled || ']');
                v_job_count := v_job_count + 1;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ℹ️  No se pudieron verificar jobs: ' || SQLERRM);
        END;
        
        -- Resumen
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== RESUMEN ===');
        DBMS_OUTPUT.PUT_LINE('📊 Tablas: ' || v_table_count);
        DBMS_OUTPUT.PUT_LINE('📊 Funciones: ' || v_function_count);
        DBMS_OUTPUT.PUT_LINE('📊 Procedimientos: ' || v_procedure_count);
        DBMS_OUTPUT.PUT_LINE('📊 Triggers: ' || v_trigger_count);
        DBMS_OUTPUT.PUT_LINE('📊 Jobs: ' || v_job_count);
        DBMS_OUTPUT.PUT_LINE('📊 Total: ' || (v_table_count + v_function_count + v_procedure_count + v_trigger_count + v_job_count));
        
    END;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ CONSTRUCCIÓN COMPLETADA EXITOSAMENTE');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/