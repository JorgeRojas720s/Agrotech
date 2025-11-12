PROMPT 
PROMPT ==================== FASE 9: JOBS PROGRAMADOS ====================

PROMPT 9.1 Job Diario: Verificación Tablespace...
@&BASE_PATH/jobs/daily/verify_tablespace_usage.sql

PROMPT 9.2 Job Diario: Verificación de Objetos Inválidos...
@&BASE_PATH/jobs/daily/verify_check_invalid_objects.sql

PROMPT 9.3 Job Diario: Verificación de Índices Corruptos...
@&BASE_PATH/jobs/daily/verify_corrupted_indexes.sql

PROMPT 9.4 Job Diario: Verificación de Cuentas Vencidas...
@&BASE_PATH/jobs/daily/verify_overdue_accounts.sql

PROMPT 9.5 Job Diario: Verificación de Visitas Técnicas...
@&BASE_PATH/jobs/daily/verify_technical_visits.sql

PROMPT 9.6 Job Mensual: Eliminación de Logs Antiguos...
@&BASE_PATH/jobs/mothly/delete_old_logs.ql