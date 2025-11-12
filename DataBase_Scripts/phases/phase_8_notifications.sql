PROMPT 
PROMPT ==================== FASE 8: NOTIFICACIONES ====================

PROMPT 8.1 Configurando ACL...
@&BASE_PATH/Notifications/acl_config/create-acl.sql

PROMPT 8.2 Verificando configuración...
@&BASE_PATH/Notifications/acl_config/verify.sql

PROMPT 8.3 Función de envío de emails...
@&BASE_PATH/Notifications/send-email.sql

PROMPT 8.4 Procedimientos de Notificación...
@&BASE_PATH/Notifications/procedures/check_corrupted_indexes.sql
@&BASE_PATH/Notifications/procedures/check_invalid_objects.sql
@&BASE_PATH/Notifications/procedures/notify_overdue_accounts.sql