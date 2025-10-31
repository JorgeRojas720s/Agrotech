-- Trigger para auditar cambios en roles del sistema
CREATE OR REPLACE TRIGGER TGR_Encrypted_Role
    AFTER CREATE OR DROP OR ALTER ON DATABASE
DECLARE
    v_event_type VARCHAR2(30);
    v_object_name VARCHAR2(30);
    v_object_type VARCHAR2(30);
BEGIN
    -- Capturar información del evento
    v_event_type := ORA_SYSEVENT;
    v_object_name := ORA_DICT_OBJ_NAME;
    v_object_type := ORA_DICT_OBJ_TYPE;
    
    -- Solo interesan los eventos de roles
    IF v_object_type = 'ROLE' THEN
        IF v_event_type = 'CREATE' THEN
            pkg_role_security.log_role_action(
                v_object_name, 
                ORA_LOGIN_USER, 
                'ROLE_CREATED',
                'Rol creado en el sistema'
            );
        ELSIF v_event_type = 'DROP' THEN
            pkg_role_security.log_role_action(
                v_object_name, 
                ORA_LOGIN_USER, 
                'ROLE_DROPPED',
                'Rol eliminado del sistema'
            );
        ELSIF v_event_type = 'ALTER' THEN
            pkg_role_security.log_role_action(
                v_object_name, 
                ORA_LOGIN_USER, 
                'ROLE_ALTERED',
                'Rol modificado en el sistema'
            );
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- No fallar por errores en el trigger
END;
/