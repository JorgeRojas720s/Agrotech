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


-- Configurar parámetros SMTP
ALTER SYSTEM SET smtp_out_server = 'smtp.gmail.com:587' SCOPE=SPFILE;

-- Si value es null usar este comando alternativo:
ALTER SYSTEM SET smtp_out_server = 'smtp.gmail.com:587' SCOPE=BOTH;


--Reiniciar la base de datos
SHUTDOWN IMMEDIATE;
STARTUP;

