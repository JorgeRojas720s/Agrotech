-- Asignar passwords a los roles existentes
BEGIN
    pkg_role_security.set_role_password('BASIC', 'BasicSecure2024!', 'SYS');
    pkg_role_security.set_role_password('MANAGER', 'ManagerSecure2024!', 'SYS');
    pkg_role_security.set_role_password('AGRONOMIST', 'AgroSecure2024!', 'SYS');
    pkg_role_security.set_role_password('TECHNICAL', 'TechSecure2024!', 'SYS');
    pkg_role_security.set_role_password('SECRETARY', 'SecretarySecure2024!', 'SYS');
END;
/

-- Verificar implementación
SELECT role_name, 
       CASE is_active WHEN 'S' THEN 'ACTIVE' ELSE 'INACTIVE' END as status,
       failed_attempts,
       last_login
FROM TBL_ROLE_SECURITY;

--! =========================================================

-- Ejemplo de uso para un agrónomo
BEGIN
    user_authenticate_role('AGRONOMIST', 'AgroSecure2024!');
    -- Ahora el usuario tiene los permisos del rol AGRONOMIST
END;
/

-- Verificar logbook
SELECT username, role_name, action_type, action_date, ip_address, details
FROM TBL_ROLE_LOGBOOK
ORDER BY action_date DESC;