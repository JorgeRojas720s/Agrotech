-- 1. Primero eliminar el ACL existente (si existe)
BEGIN
    DBMS_NETWORK_ACL_ADMIN.DROP_ACL(
        acl => 'smtp_gmail_acl.xml'
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Si no existe, continuar
        NULL;
END;
/

-- 2. Crear el ACL nuevamente
BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(
        acl => 'smtp_gmail_acl.xml',
        description => 'ACL para SMTP Gmail',
        principal => 'SYS',  
        is_grant => TRUE,
        privilege => 'connect'
    );
    
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
        acl => 'smtp_gmail_acl.xml',
        principal => 'SYS',
        is_grant => TRUE,
        privilege => 'resolve'
    );
    
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(
        acl => 'smtp_gmail_acl.xml',
        host => 'smtp.gmail.com'
    );
    
    COMMIT;
END;
/

-- 3. Verificar que se creó correctamente
SELECT acl, principal, privilege, is_grant 
FROM dba_network_acl_privileges 
WHERE acl LIKE '%smtp_gmail%';

-- 4. Configurar parámetros SMTP
ALTER SYSTEM SET smtp_out_server = 'smtp.gmail.com:587' SCOPE=SPFILE;

-- 5. Reiniciar la base de datos
SHUTDOWN IMMEDIATE;
STARTUP;



-- Verificar después del reinicio
SELECT name, value FROM v$parameter WHERE name = 'smtp_out_server';
-----------------------------------------


-- Configurar el parámetro SMTP
ALTER SYSTEM SET smtp_out_server = 'smtp.gmail.com:587' SCOPE=SPFILE;

-- Verificar que quedó configurado
SELECT name, value FROM v$parameter WHERE name = 'smtp_out_server';

-- Si sigue null, usar este comando alternativo:
ALTER SYSTEM SET smtp_out_server = 'smtp.gmail.com:587' SCOPE=BOTH;

-- O intentar con este formato:
ALTER SYSTEM SET smtp_out_server = '(smtp.gmail.com:587)' SCOPE=SPFILE;


--------------------------


-- Verificar que todo está configurado
-- 1. Ver ACL
SELECT * FROM dba_network_acls;

-- 2. Ver privilegios
SELECT * FROM dba_network_acl_privileges WHERE principal = 'SYS';

-- 3. Ver parámetro SMTP
SELECT name, value FROM v$parameter WHERE name LIKE 'smtp%';

-- 4. Probar resolución de DNS
SELECT UTL_INADDR.get_host_address('smtp.gmail.com') FROM DUAL;



----------------
--!Eliminar
-- Ejecutar como SYS
BEGIN
    DBMS_NETWORK_ACL_ADMIN.DROP_ACL('smtp_gmail_acl.xml');
    COMMIT;
END;
/

-- Verificar que se eliminó
SELECT * FROM dba_network_acls WHERE acl LIKE '%smtp_gmail%';


-----------------------------------


-- Verificar ACL
SELECT acl, principal, privilege, is_grant 
FROM dba_network_acl_privileges 
WHERE acl LIKE '%smtp_gmail%';

-- Verificar resolución DNS
SELECT UTL_INADDR.get_host_address('smtp.gmail.com') FROM DUAL;

-- Probar conexión básica
DECLARE
    v_conn UTL_SMTP.connection;
BEGIN
    v_conn := UTL_SMTP.OPEN_CONNECTION('smtp.gmail.com', 587);
    DBMS_OUTPUT.PUT_LINE('Conexión exitosa');
    UTL_SMTP.QUIT(v_conn);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error conexión: ' || SQLERRM);
END;
/