SET ECHO ON
SET FEEDBACK ON
SET TIMING ON
SET SERVEROUTPUT ON SIZE UNLIMITED
DEFINE BASE_PATH = "C:\Users\yzmam\Documents\database\Agrotech\DataBase_Scripts"

PROMPT ========================================
PROMPT   EJECUCIÓN COMPLETA - AGROTECH DATABASE
PROMPT ========================================
PROMPT Iniciando: &&_START_DATE &&_START_TIME

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CONSTRUCCIÓN DE BASE DE DATOS ===');
END;
/


-- ==================== FASE 1: ESTRUCTURA PRINCIPAL ====================

PROMPT 
PROMPT 1. ELIMINANDO TABLAS EXISTENTES...
@&BASE_PATH/structure/drop_tables.sql

PROMPT 
PROMPT 2. CREANDO TABLAS PRINCIPALES...
@&BASE_PATH/structure/script.sql

-- ==================== FASE 2: TABLESPACES ====================

PROMPT 
PROMPT 3. CREANDO TABLESPACES...

PROMPT 3.1 Tablespace: MASTER_DATA...
@&BASE_PATH/structure/tablespaces/master_data/master_data.sql
@&BASE_PATH/structure/tablespaces/master_data/index.sql

PROMPT 3.2 Tablespace: CATALOGS...
@&BASE_PATH/structure/tablespaces/catalogs/catalogs.sql
@&BASE_PATH/structure/tablespaces/catalogs/index.sql

PROMPT 3.3 Tablespace: FINANCE...
@&BASE_PATH/structure/tablespaces/finance/finance.sql
@&BASE_PATH/structure/tablespaces/finance/index.sql

PROMPT 3.4 Tablespace: AGRICULTURAL_OPERATIONS...
@&BASE_PATH/structure/tablespaces/agricultural_operations/agricultural_operations.sql
@&BASE_PATH/structure/tablespaces/agricultural_operations/index.sql

PROMPT 3.5 Tablespace: PEST_TREATMENTS...
@&BASE_PATH/structure/tablespaces/pest_treatments/pest_treatments.sql
@&BASE_PATH/structure/tablespaces/pest_treatments/index.sql

PROMPT 3.6 Tablespace: SCHEDULING_APPOINTMENTS...
@&BASE_PATH/structure/tablespaces/scheduling_appointments/scheduling_appointments.sql
@&BASE_PATH/structure/tablespaces/scheduling_appointments/index.sql

PROMPT 3.7 Tablespace: TECHNICAL_ENVIRONMENTAL...
@&BASE_PATH/structure/tablespaces/technical_environmental/technical_enviromental.sql
@&BASE_PATH/structure/tablespaces/technical_environmental/index.sql

PROMPT 3.8 Tablespace: MONITORING_LOG...
@&BASE_PATH/structure/tablespaces/ts_monitoring_log.sql

PROMPT 3.9 Verificando tablespaces...
@&BASE_PATH/structure/tablespaces/verify_tablespaces.sql

-- ==================== FASE 3: FUNCIONES ====================

PROMPT 
PROMPT 4. CARGANDO FUNCIONES...

PROMPT 4.1 Función: AUTO-INCREMENT...
@&BASE_PATH/functions/auto-increment.sql

PROMPT 4.2 Función: CANCEL-VISIT...
@&BASE_PATH/functions/cancel-visit.sql

PROMPT 4.3 Función: SENASA-CASES...
@&BASE_PATH/functions/senasa-cases.sql

PROMPT 4.4 Función: UPDATE-TECHFILE...
@&BASE_PATH/functions/update-techfile.sql

-- ==================== FASE 4: SEGURIDAD ====================

PROMPT 
PROMPT 5. CONFIGURANDO SEGURIDAD...

PROMPT 5.1 Creando perfiles...
@&BASE_PATH/security/basic/profiles.sql

PROMPT 5.2 Creando roles...
@&BASE_PATH/security/basic/roles.sql

PROMPT 5.3 Creando usuarios...
@&BASE_PATH/security/basic/users.sql

-- ==================== FASE 5: LOGBOOKS ====================

PROMPT 
PROMPT 6. CREANDO LOGBOOKS...

PROMPT 6.1 Logbook: AGRONOMIC_VISITS...
@&BASE_PATH/security/logbooks/agronomic_visits/logook.sql

PROMPT 6.2 Logbook: AGRONOMIST_CHANGES...
@&BASE_PATH/security/logbooks/agronomist_changes/logbook.sql

PROMPT 6.3 Logbook: APPLIED_TREATMENTS...
@&BASE_PATH/security/logbooks/applied_treatments/logbook.sql

PROMPT 6.4 Logbook: AVAILABILITY_CHANGES...
@&BASE_PATH/security/logbooks/availability_changes/logbook.sql

PROMPT 6.5 Logbook: CROP_HISTORY...
@&BASE_PATH/security/logbooks/crop_history/logbook.sql

PROMPT 6.6 Logbook: DATA_MODIFICATIONS...
@&BASE_PATH/security/logbooks/data_modifications/logbook.sql

PROMPT 6.7 Logbook: FIELD_INSPECTIONS...
@&BASE_PATH/security/logbooks/field_inspections/logbook.sql

PROMPT 6.8 Logbook: LABORATORY_ANALYSIS...
@&BASE_PATH/security/logbooks/laboratory_analysis/logbook.sql

PROMPT 6.9 Logbook: SYSTEM_ERRORS...
@&BASE_PATH/security/logbooks/system_errors/logbook.sql

-- ==================== FASE 6: TRIGGERS ====================

PROMPT 
PROMPT 7. CREANDO TRIGGERS...

PROMPT 7.1 Trigger: AGRONOMIC_VISITS...
@&BASE_PATH/security/logbooks/agronomic_visits/trigger.sql

PROMPT 7.2 Trigger: AGRONOMIST_CHANGES...
@&BASE_PATH/security/logbooks/agronomist_changes/trigger.sql

PROMPT 7.3 Trigger: APPLIED_TREATMENTS...
@&BASE_PATH/security/logbooks/applied_treatments/trigger.sql

PROMPT 7.4 Trigger: AVAILABILITY_CHANGES...
@&BASE_PATH/security/logbooks/availability_changes/trigger.sql

PROMPT 7.5 Trigger: CROP_HISTORY...
@&BASE_PATH/security/logbooks/crop_history/trigger.sql

PROMPT 7.6 Trigger: DATA_MODIFICATIONS...
@&BASE_PATH/security/logbooks/data_modifications/trigger.sql

PROMPT 7.7 Trigger: FIELD_INSPECTIONS...
@&BASE_PATH/security/logbooks/field_inspections/trigger.sql

PROMPT 7.8 Trigger: LABORATORY_ANALYSIS...
@&BASE_PATH/security/logbooks/laboratory_analysis/trigger.sql

PROMPT 7.9 Trigger: SYSTEM_ERRORS...
@&BASE_PATH/security/logbooks/system_errors/trigger.sql

-- ==================== FASE 7: NOTIFICACIONES ====================

PROMPT 
PROMPT 8. CONFIGURANDO NOTIFICACIONES...

PROMPT 8.1 Configurando ACL...
@&BASE_PATH/Notifications/acl_config/create-acl.sql

PROMPT 8.2 Verificando configuración...
@&BASE_PATH/Notifications/acl_config/verify.sql

PROMPT 8.3 Función de envío de emails...
@&BASE_PATH/Notifications/send-email.sql

-- ==================== FASE 8: JOBS PROGRAMADOS ====================

PROMPT 
PROMPT 9. PROGRAMANDO JOBS...

PROMPT 9.1 Job Diario: Verificación Tablespace...
@&BASE_PATH/jobs/daily/verify_tablespace_usage.sql

-- ==================== FASE 9: VERIFICACIÓN FINAL ====================

PROMPT 
PROMPT 10. VERIFICACIÓN FINAL...

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== VERIFICANDO OBJETOS CREADOS ===');
    
    -- Verificar tablas
    FOR t IN (SELECT table_name, num_rows 
              FROM user_tables 
              ORDER BY table_name) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('✅ Tabla: ' || t.table_name);
    END LOOP;
    
    -- Verificar funciones
    FOR f IN (SELECT object_name 
              FROM user_objects 
              WHERE object_type = 'FUNCTION'
              ORDER BY object_name) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('✅ Función: ' || f.object_name);
    END LOOP;
    
    -- Verificar triggers
    FOR trg IN (SELECT trigger_name 
                FROM user_triggers 
                ORDER BY trigger_name) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('✅ Trigger: ' || trg.trigger_name);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('✅ CONSTRUCCIÓN COMPLETADA EXITOSAMENTE');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

PROMPT 
PROMPT ========================================
PROMPT   EJECUCIÓN COMPLETADA
PROMPT ========================================
PROMPT Finalizado: &&_END_DATE &&_END_TIME

EXIT;