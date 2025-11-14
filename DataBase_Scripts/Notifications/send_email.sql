
CREATE OR REPLACE PROCEDURE pcr_send_email(
    p_recipient IN VARCHAR2,
    p_subject IN VARCHAR2,
    p_message IN VARCHAR2
) AS
    v_conn UTL_SMTP.connection;
    v_usuario VARCHAR2(50) := 'ismael.marchena.mendez@est.una.ac.cr'; --!Cambiar por su correo
    v_password VARCHAR2(50) := 'tter wsvy zdml'; --!Cambiar por su app password
    v_username_encoded VARCHAR2(1000);
    v_password_encoded VARCHAR2(1000);
BEGIN
    v_conn := UTL_SMTP.OPEN_CONNECTION(
        host => 'smtp.gmail.com',
        port => 587,
        wallet_path => 'file:/home/oracle/smtp_wallet',        
        wallet_password => 'Agrotech123' --!Cambiar por su password del wallet
    );
    
    DBMS_OUTPUT.PUT_LINE('Conexión establecida...');
    
    UTL_SMTP.EHLO(v_conn, 'oracle-server');
    DBMS_OUTPUT.PUT_LINE('EHLO enviado...');
    
    UTL_SMTP.STARTTLS(v_conn);
    DBMS_OUTPUT.PUT_LINE('TLS iniciado...');
    
    UTL_SMTP.EHLO(v_conn, 'oracle-server');
    DBMS_OUTPUT.PUT_LINE('EHLO después de TLS...');
    
    -- Autenticación con AUTH LOGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando autenticación LOGIN...');
    
    v_username_encoded := UTL_RAW.CAST_TO_VARCHAR2(
        UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(v_usuario))
    );
    
    v_password_encoded := UTL_RAW.CAST_TO_VARCHAR2(
        UTL_ENCODE.BASE64_ENCODE(UTL_RAW.CAST_TO_RAW(v_password))
    );
    
    DBMS_OUTPUT.PUT_LINE('Enviando AUTH LOGIN...');
    UTL_SMTP.COMMAND(v_conn, 'AUTH LOGIN');
    
    DBMS_OUTPUT.PUT_LINE('Enviando username...');
    UTL_SMTP.COMMAND(v_conn, v_username_encoded);
    
    DBMS_OUTPUT.PUT_LINE('Enviando password...');
    UTL_SMTP.COMMAND(v_conn, v_password_encoded);
    
    DBMS_OUTPUT.PUT_LINE('Autenticación completada...');
    
    UTL_SMTP.MAIL(v_conn, v_usuario);
    UTL_SMTP.RCPT(v_conn, p_recipient);
    
    UTL_SMTP.OPEN_DATA(v_conn);
    UTL_SMTP.WRITE_DATA(v_conn, 'From: ' || v_usuario || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(v_conn, 'To: ' || p_recipient || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(v_conn, 'Subject: ' || p_subject || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(v_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(v_conn, UTL_TCP.CRLF);
    UTL_SMTP.WRITE_DATA(v_conn, p_message || UTL_TCP.CRLF);
    UTL_SMTP.CLOSE_DATA(v_conn);
    
    DBMS_OUTPUT.PUT_LINE('Mensaje enviado...');
    
    UTL_SMTP.QUIT(v_conn);
    
    DBMS_OUTPUT.PUT_LINE('✅ Email enviado exitosamente a: ' || p_recipient);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error al enviar email: ' || SQLERRM);
        BEGIN
            UTL_SMTP.QUIT(v_conn);
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        RAISE;
END pcr_send_email;
/

------------------------------------------------------------------------------

-- --! Probar el envío
-- BEGIN
--     pcr_send_email(
--         p_recipient => 'jorge.rojas.mena@est.una.ac.cr', 
--         p_subject => 'Hello',
--         p_message => 'Gepeto Mamahuevo' || CHR(10) || CHR(10) || 'Att: El sysdba'
--     );
-- END;