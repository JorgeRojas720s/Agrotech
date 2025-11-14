-- Cargar configuración
@config/config.sql

DEFINE BASE_PATH = "C:\Users\yzmam\Documents\database\Agrotech\DataBase_Scripts"

-- Variables de tiempo
COLUMN START_DATE NEW_VALUE _START_DATE
COLUMN START_TIME NEW_VALUE _START_TIME
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS START_DATE, 
       TO_CHAR(SYSDATE, 'HH24:MI:SS') AS START_TIME 
FROM DUAL;

PROMPT ========================================
PROMPT   EJECUCIÓN COMPLETA - AGROTECH DATABASE
PROMPT ========================================
PROMPT Iniciando: &&_START_DATE &&_START_TIME

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO CONSTRUCCIÓN DE BASE DE DATOS ===');
END;
/

-- Ejecutar fases modulares
@phases/phase_1_structure.sql
@phases/phase_5_logbooks.sql
@phases/phase_8_notifications.sql
@phases/phase_2_tablespaces.sql
@phases/phase_3_functions.sql
@phases/phase_6_logs_tablespace.sql
@phases/phase_7_triggers.sql
@phases/phase_10_verification.sql

-- Finalización
COLUMN END_DATE NEW_VALUE _END_DATE
COLUMN END_TIME NEW_VALUE _END_TIME
SELECT TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS END_DATE, 
       TO_CHAR(SYSDATE, 'HH24:MI:SS') AS END_TIME 
FROM DUAL;

PROMPT 
PROMPT ========================================
PROMPT   EJECUCIÓN COMPLETADA
PROMPT ========================================
PROMPT Finalizado: &&_END_DATE &&_END_TIME

EXIT;
