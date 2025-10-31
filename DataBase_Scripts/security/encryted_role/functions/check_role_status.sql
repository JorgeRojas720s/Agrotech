-- Función para verificar estado del rol
CREATE OR REPLACE FUNCTION check_role_status(p_role_name IN VARCHAR2) RETURN VARCHAR2 AS
    v_is_active CHAR(1);
    v_failed_attempts NUMBER;
BEGIN
    SELECT is_active, failed_attempts
    INTO v_is_active, v_failed_attempts
    FROM TBL_ROLE_SECURITY
    WHERE role_name = p_role_name;
    
    RETURN CASE 
        WHEN v_is_active = 'N' THEN 'INACTIVE'
        WHEN v_failed_attempts >= 5 THEN 'LOCKED'
        ELSE 'ACTIVE'
    END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NOT_SECURED';
END;
/