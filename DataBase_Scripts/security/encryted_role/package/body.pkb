CREATE OR REPLACE PACKAGE BODY pkg_role_security AS

    FUNCTION encrypt_password(p_password IN VARCHAR2, p_salt IN RAW DEFAULT NULL) RETURN RAW IS
        v_salt RAW(32);
        v_encrypted RAW(256);
    BEGIN
        -- Generar salt si no se proporciona
        IF p_salt IS NULL THEN
            v_salt := DBMS_CRYPTO.RANDOMBYTES(32);
        ELSE
            v_salt := p_salt;
        END IF;
        
        -- Encriptar password usando SHA-256 con salt
        v_encrypted := DBMS_CRYPTO.HASH(
            utl_i18n.string_to_raw(p_password || RAWTOHEX(v_salt), 'AL32UTF8'),
            DBMS_CRYPTO.HASH_SH256
        );
        
        RETURN v_encrypted;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error encriptando password: ' || SQLERRM);
    END encrypt_password;

    FUNCTION verify_password(p_role_name IN VARCHAR2, p_password IN VARCHAR2) RETURN BOOLEAN IS
        v_stored_encrypted RAW(256);
        v_salt RAW(32);
        v_calculated_encrypted RAW(256);
        v_is_active CHAR(1);
        v_failed_attempts NUMBER;
    BEGIN
        -- Obtener datos del rol
        SELECT encrypted_password, salt, is_active, failed_attempts
        INTO v_stored_encrypted, v_salt, v_is_active, v_failed_attempts
        FROM TBL_ROLE_SECURITY
        WHERE role_name = p_role_name;
        
        -- Verificar si el rol está activo
        IF v_is_active = 'N' THEN
            RAISE_APPLICATION_ERROR(-20002, 'El rol está desactivado');
        END IF;
        
        -- Verificar intentos fallidos
        IF v_failed_attempts >= 5 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Rol bloqueado por demasiados intentos fallidos');
        END IF;
        
        -- Calcular hash del password proporcionado
        v_calculated_encrypted := encrypt_password(p_password, v_salt);
        
        -- Comparar hashes
        IF v_stored_encrypted = v_calculated_encrypted THEN
            -- Password correcto, resetear intentos fallidos
            UPDATE TBL_ROLE_SECURITY 
            SET failed_attempts = 0, last_login = SYSTIMESTAMP
            WHERE role_name = p_role_name;
            COMMIT;
            RETURN TRUE;
        ELSE
            -- Password incorrecto, incrementar intentos fallidos
            UPDATE TBL_ROLE_SECURITY 
            SET failed_attempts = failed_attempts + 1
            WHERE role_name = p_role_name;
            COMMIT;
            RETURN FALSE;
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RAISE;
    END verify_password;

    PROCEDURE set_role_password(p_role_name IN VARCHAR2, p_password IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER) IS
        v_salt RAW(32);
        v_encrypted RAW(256);
        v_count NUMBER;
    BEGIN
        -- Verificar que el rol existe
        SELECT COUNT(*) INTO v_count FROM dba_roles WHERE role = p_role_name;
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El rol ' || p_role_name || ' no existe');
        END IF;
        
        -- Verificar que el password no esté vacío
        IF p_password IS NULL OR LENGTH(p_password) < 6 THEN
            RAISE_APPLICATION_ERROR(-20005, 'El password debe tener al menos 6 caracteres');
        END IF;
        
        -- Generar salt
        v_salt := DBMS_CRYPTO.RANDOMBYTES(32);
        
        -- Encriptar password
        v_encrypted := encrypt_password(p_password, v_salt);
        
        -- Insertar o actualizar registro
        MERGE INTO TBL_ROLE_SECURITY rs
        USING (SELECT p_role_name as role_name FROM dual) src
        ON (rs.role_name = src.role_name)
        WHEN MATCHED THEN
            UPDATE SET 
                encrypted_password = v_encrypted,
                salt = v_salt,
                last_modified = SYSTIMESTAMP,
                failed_attempts = 0,
                is_active = 'S'
        WHEN NOT MATCHED THEN
            INSERT (role_name, encrypted_password, salt)
            VALUES (p_role_name, v_encrypted, v_salt);
        
        COMMIT;
        
        -- Registrar en logbook
        log_role_action(p_role_name, p_admin_user, 'PASSWORD_CHANGE', 'Password actualizado exitosamente');
        
        DBMS_OUTPUT.PUT_LINE('Password asignado exitosamente al rol: ' || p_role_name);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20006, 'Error asignando password al rol: ' || SQLERRM);
    END set_role_password;

    PROCEDURE authenticate_role(p_role_name IN VARCHAR2, p_password IN VARCHAR2, p_username IN VARCHAR2 DEFAULT USER) IS
        v_authenticated BOOLEAN;
        v_client_info VARCHAR2(100);
    BEGIN
        -- Verificar autenticación
        v_authenticated := verify_password(p_role_name, p_password);
        
        IF v_authenticated THEN
            -- Asignar rol al usuario
            EXECUTE IMMEDIATE 'SET ROLE ' || p_role_name || ' IDENTIFIED BY ' || p_password;
            
            -- Registrar éxito en logbook
            log_role_action(p_role_name, p_username, 'LOGIN_SUCCESS', 
                'Autenticación exitosa desde: ' || SYS_CONTEXT('USERENV', 'IP_ADDRESS'));
            
            DBMS_OUTPUT.PUT_LINE('Rol ' || p_role_name || ' autenticado exitosamente');
        ELSE
            -- Registrar fallo en logbook
            log_role_action(p_role_name, p_username, 'LOGIN_FAILED', 
                'Password incorrecto desde: ' || SYS_CONTEXT('USERENV', 'IP_ADDRESS'));
            
            RAISE_APPLICATION_ERROR(-20007, 'Password incorrecto para el rol: ' || p_role_name);
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            log_role_action(p_role_name, p_username, 'LOGIN_FAILED', 
                'Error en autenticación: ' || SQLERRM);
            RAISE;
    END authenticate_role;

    PROCEDURE disable_role(p_role_name IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER) IS
    BEGIN
        UPDATE TBL_ROLE_SECURITY 
        SET is_active = 'N', last_modified = SYSTIMESTAMP
        WHERE role_name = p_role_name;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Rol no encontrado en sistema de seguridad: ' || p_role_name);
        END IF;
        
        COMMIT;
        
        log_role_action(p_role_name, p_admin_user, 'ROLE_DISABLED', 'Rol desactivado por administrador');
        
        DBMS_OUTPUT.PUT_LINE('Rol ' || p_role_name || ' desactivado exitosamente');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END disable_role;

    PROCEDURE enable_role(p_role_name IN VARCHAR2, p_admin_user IN VARCHAR2 DEFAULT USER) IS
    BEGIN
        UPDATE TBL_ROLE_SECURITY 
        SET is_active = 'S', failed_attempts = 0, last_modified = SYSTIMESTAMP
        WHERE role_name = p_role_name;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20009, 'Rol no encontrado en sistema de seguridad: ' || p_role_name);
        END IF;
        
        COMMIT;
        
        log_role_action(p_role_name, p_admin_user, 'ROLE_ENABLED', 'Rol reactivado por administrador');
        
        DBMS_OUTPUT.PUT_LINE('Rol ' || p_role_name || ' reactivado exitosamente');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END enable_role;

    FUNCTION role_requires_auth(p_role_name IN VARCHAR2) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TBL_ROLE_SECURITY
        WHERE role_name = p_role_name AND is_active = 'S';
        
        RETURN v_count > 0;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END role_requires_auth;

    PROCEDURE log_role_action(
        p_role_name IN VARCHAR2,
        p_username IN VARCHAR2,
        p_action_type IN VARCHAR2,
        p_details IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO TBL_ROLE_LOGBOOK (
            log_id, role_name, username, action_type, 
            ip_address, session_id, details
        ) VALUES (
            role_logbook_seq.NEXTVAL, p_role_name, p_username, p_action_type,
            SYS_CONTEXT('USERENV', 'IP_ADDRESS'), 
            SYS_CONTEXT('USERENV', 'SESSIONID'),
            p_details
        );
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- No fallar si el log falla
    END log_role_action;

END pkg_role_security;
/