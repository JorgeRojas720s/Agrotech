
--Verificar que se creó correctamente
SELECT acl, principal, privilege, is_grant 
FROM dba_network_acl_privileges 
WHERE acl LIKE '%smtp_gmail%';


-- 1. Ver ACL
SELECT * FROM dba_network_acls;

-- 2. Ver privilegios
SELECT * FROM dba_network_acl_privileges WHERE principal = 'SYS';

-- 3. Verificar que quedó configurado el parámetro SMTP
SELECT name, value FROM v$parameter WHERE name LIKE 'smtp%';

-- o este
SELECT name, value FROM v$parameter WHERE name = 'smtp_out_server';

-- 4. Probar resolución de DNS
SELECT UTL_INADDR.get_host_address('smtp.gmail.com') FROM DUAL;