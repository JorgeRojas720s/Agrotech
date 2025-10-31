CREATE OR REPLACE PACKAGE pkg_role_security AS
    -- Función para encriptar password
    FUNCTION encrypt_password(p_password IN VARCHAR2, p_salt IN RAW DEFAULT NULL) RETURN RAW;
    
    -- Función para verificar password
    FUNCTION verify_password(p_role_name IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN;
    
    -- Procedimiento para asignar/actualizar password a rol
    PROCEDURE set_role_password(p_role_name IN VARCHAR2, p_password IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER);
    
    -- Procedimiento para autenticar rol
    PROCEDURE authenticate_role(p_role_name IN VARCHAR2, p_password IN VARCHAR2, p_username IN VARCHAR2 DEFAULT USER);
    
    -- Procedimiento para desactivar rol
    PROCEDURE disable_role(p_role_name IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER);
    
    -- Procedimiento para reactivar rol
    PROCEDURE enable_role(p_role_name IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER);
    
    -- Función para verificar si rol requiere autenticación
    FUNCTION role_requires_auth(p_role_name IN VARCHAR2) RETURN BOOLEAN;
    
    -- Procedimiento para registrar en logbook
    PROCEDURE log_role_action(
        p_role_name IN VARCHAR2,
        p_username IN VARCHAR2,
        p_action_type IN VARCHAR2,
        p_details IN VARCHAR2 DEFAULT NULL
    );
    
END pkg_role_security;
/