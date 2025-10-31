-- Procedimiento simplificado para usuarios finales
CREATE OR REPLACE PROCEDURE user_authenticate_role(
    p_role_name IN VARCHAR2,
    p_password IN VARCHAR2
) AS
BEGIN
    pkg_role_security.authenticate_role(p_role_name, p_password, USER);
END;
/
