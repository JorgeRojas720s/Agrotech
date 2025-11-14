PROMPT 
PROMPT ==================== FASE 4: SEGURIDAD ====================

PROMPT 5.1 Creando perfiles...
@&BASE_PATH/security/basic/profiles.sql

PROMPT 5.2 Creando roles...
@&BASE_PATH/security/basic/roles.sql

PROMPT 5.3 Creando usuarios...
@&BASE_PATH/security/basic/users.sql

PROMPT 5.4 Configurando Rol Encriptado...
@&BASE_PATH/security/encryted_role/table.sql
@&BASE_PATH/security/encryted_role/example.sql

PROMPT 5.5 Funciones de Autenticación...
@&BASE_PATH/security/encryted_role/functions/authenticate_role.sql
@&BASE_PATH/security/encryted_role/functions/check_role_status.sql