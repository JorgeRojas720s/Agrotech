CREATE OR REPLACE PROCEDURE pcr_notify_overdue_accounts AS
    CURSOR c_overdue_accounts IS
        SELECT 
            a.acc_id,
            a.acc_amount,
            a.acc_date,
            p.pro_id,
            per.per_name,
            per.per_lastname,
            con.con_contact as email,
            TRUNC(MONTHS_BETWEEN(SYSDATE, a.acc_date)) as months_overdue
        FROM TBL_ACCOUNT a
        JOIN TBL_PERSON per ON a.acc_person_id = per.per_id
        JOIN TBL_PRODUCERS p ON per.per_id = p.pro_person_id
        JOIN TBL_PER_X_CON pxc ON per.per_id = pxc.pxc_person_id
        JOIN TBL_CONTACTS con ON pxc.pxc_contact_id = con.con_id
        WHERE a.acc_state = 'PAGADO'  -- Cambié a 'PAGADO' según tu CHECK constraint
          AND con.con_type = 'EMAIL'
          AND MONTHS_BETWEEN(SYSDATE, a.acc_date) > 1
          AND NOT EXISTS (
              SELECT 1 FROM TBL_NOTIFICATION_LOG nol
              WHERE nol.nol_account_id = a.acc_id
                AND nol.nol_notification_type = 'OVERDUE_ACCOUNT'
                AND TRUNC(nol.nol_sent_date) = TRUNC(SYSDATE)
          );
    
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_success_count NUMBER := 0;
    v_error_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando notificación de cuentas pendientes...');
    DBMS_OUTPUT.PUT_LINE('Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    
    FOR rec IN c_overdue_accounts LOOP
        BEGIN
            -- Construir asunto y mensaje
            v_subject := 'Recordatorio de Cuenta Pendiente - ' || rec.months_overdue || ' mes(es) de antigüedad';
            
            v_message := 
                'Estimado(a) ' || rec.per_name || ' ' || rec.per_lastname || ',' || CHR(10) || CHR(10) ||
                'Le informamos que tiene una cuenta pendiente con las siguientes características:' || CHR(10) || CHR(10) ||
                'Detalles de la cuenta:' || CHR(10) ||
                '   • Monto pendiente: ₡' || TO_CHAR(rec.acc_amount, '999,999,999.00') || CHR(10) ||
                '   • Fecha de generación: ' || TO_CHAR(rec.acc_date, 'DD/MM/YYYY') || CHR(10) ||
                '   • Tiempo de antigüedad: ' || rec.months_overdue || ' mes(es)' || CHR(10) || CHR(10) ||
                'Por favor, regularice su situación lo antes posible.' || CHR(10) || CHR(10) ||
                'Para más información, puede contactarnos a través de nuestros canales habituales.' || CHR(10) || CHR(10) ||
                'Atentamente,' || CHR(10) ||
                'Equipo de Servicios Agrícolas' || CHR(10) ||
                '---' || CHR(10) ||
                'Este es un mensaje automático, por favor no responda.';
            
            -- Enviar email
            pcr_send_email(
                p_recipient => rec.email,
                p_subject => v_subject,
                p_message => v_message
            );
            
            -- Registrar en log
            INSERT INTO TBL_NOTIFICATION_LOG (
                nol_id, nol_account_id, nol_producer_id, 
                nol_notification_type, nol_status
            ) VALUES (
                seq_notification_log.NEXTVAL, rec.acc_id, rec.pro_id,
                'OVERDUE_ACCOUNT', 'ENVIADO'
            );
            
            v_success_count := v_success_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Notificación enviada a: ' || rec.per_name || ' ' || rec.per_lastname || 
                               ' - Monto: ₡' || TO_CHAR(rec.acc_amount, '999,999,999.00'));
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Registrar error en log
                INSERT INTO TBL_NOTIFICATION_LOG (
                    nol_id, nol_account_id, nol_producer_id, 
                    nol_notification_type, nol_status, nol_error_message
                ) VALUES (
                    seq_notification_log.NEXTVAL, rec.acc_id, rec.pro_id,
                    'OVERDUE_ACCOUNT', 'ERROR', SQLERRM
                );
                
                v_error_count := v_error_count + 1;
                DBMS_OUTPUT.PUT_LINE('Error enviando a ' || rec.per_name || ' ' || rec.per_lastname || 
                                   ': ' || SQLERRM);
        END;
    END LOOP;
    
    -- Resumen final
    DBMS_OUTPUT.PUT_LINE('=================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE NOTIFICACIONES:');
    DBMS_OUTPUT.PUT_LINE('   Enviadas exitosamente: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('   Errores: ' || v_error_count);
    DBMS_OUTPUT.PUT_LINE('   Total procesados: ' || (v_success_count + v_error_count));
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error crítico en el proceso: ' || SQLERRM);
        RAISE;
END pcr_notify_overdue_accounts;
/