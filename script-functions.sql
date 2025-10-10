-- =========================================
-- Cuando se cancele mediante administracion la visita tecnica
-- automaticamente esta debera cambiar su estado.
-- =========================================
CREATE OR REPLACE TRIGGER TRG_CANCEL_VISIT_STATUS
AFTER INSERT ON TBL_CANCELLED_HISTORIES
FOR EACH ROW
DECLARE
    v_ava_id NUMBER;
BEGIN
    -- 1. Obtener la disponibilidad asociada a la visita cancelada
    SELECT vis_available_id
    INTO v_ava_id
    FROM TBL_VISITS
    WHERE vis_id = :NEW.cah_visit_id;

    -- 2. Actualizar su estado a 'CANCELADO'
    UPDATE TBL_AVAILABILITIES
    SET ava_available = 'CANCELADO'
    WHERE ava_id = v_ava_id;

    -- 3. Confirmar cambio
    DBMS_OUTPUT.PUT_LINE('Visita ' || :NEW.cah_visit_id || ' cancelada correctamente.');
END;
/

-- =========================================
-- Las llaves primarias deben de ser numeros consecutivos e incluirlo de forma
-- automatica por cada registro insertado.
-- =========================================
CREATE SEQUENCE SEQ_TBL_VISITS
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_TBL_VISITS_AI
BEFORE INSERT ON TBL_VISITS
FOR EACH ROW
BEGIN
    IF :NEW.vis_id IS NULL THEN
        SELECT SEQ_TBL_VISITS.NEXTVAL
        INTO :NEW.vis_id
        FROM DUAL;
    END IF;
END;
/

CREATE SEQUENCE SEQ_TBL_CANCELLED_HISTORIES
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_TBL_CANCELLED_HISTORIES_AI
BEFORE INSERT ON TBL_CANCELLED_HISTORIES
FOR EACH ROW
BEGIN
    IF :NEW.cah_id IS NULL THEN
        SELECT SEQ_TBL_CANCELLED_HISTORIES.NEXTVAL
        INTO :NEW.cah_id
        FROM DUAL;
    END IF;
END;
/

CREATE SEQUENCE SEQ_TBL_AVAILABILITIES
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_TBL_AVAILABILITIES_AI
BEFORE INSERT ON TBL_AVAILABILITIES
FOR EACH ROW
BEGIN
    IF :NEW.ava_id IS NULL THEN
        SELECT SEQ_TBL_AVAILABILITIES.NEXTVAL
        INTO :NEW.ava_id
        FROM DUAL;
    END IF;
END;
/

CREATE SEQUENCE SEQ_TBL_PRODUCERS
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE OR REPLACE TRIGGER TRG_TBL_PRODUCERS_AI
BEFORE INSERT ON TBL_PRODUCERS
FOR EACH ROW
BEGIN
    IF :NEW.pro_id IS NULL THEN
        SELECT SEQ_TBL_PRODUCERS.NEXTVAL
        INTO :NEW.pro_id
        FROM DUAL;
    END IF;
END;
/

-- MISMA IDEA PARA TODAS LAS TABLAS...


-- =========================================
-- Cada dia se le enviara un correo al agronomo o al correo asignado a la
-- especialidad de las visitas tecnicas programadas para el dia siguiente.
-- =========================================
-- Vista con las visitas programadas para "maniana"
CREATE OR REPLACE VIEW V_VISITS_TOMORROW AS
SELECT
    v.vis_id,
    v.vis_slots,
    v.vis_attendance,
    a.ava_id,
    -- Fecha de la visita (tomamos la fecha de agenda del agronomo si existe, si no la de la especialidad)
    TRUNC(COALESCE(CAST(sca.sca_date AS DATE), CAST(scs.scs_date AS DATE))) AS visit_date,
    -- Ventana horaria (si no hay una de las dos, mostramos la disponible)
    COALESCE(sca.sca_start_time, scs.scs_start_time) AS start_hour,
    COALESCE(sca.sca_end_time,   scs.scs_end_time)   AS end_hour,

    -- Contexto agronomo
    agr.agr_id,
    per_agr.per_name || ' ' || per_agr.per_lastname AS agronomist_name,
    -- Un email del agronomo (si tiene varios, tomamos el primero alfabetico)
    (SELECT MIN(ca.con_contact)
       FROM TBL_PER_X_CON pca
       JOIN TBL_CONTACTS ca ON ca.con_id = pca.pxc_contact_id AND ca.con_type = 'EMAIL'
      WHERE pca.pxc_person_id = per_agr.per_id) AS agronomist_email,

    -- Contexto especialidad
    spe.spe_id,
    spe.spe_type AS speciality_name,
    -- Un email 'de la especialidad' (tomamos un email de la empresa que ofrece esa especialidad)
    (SELECT MIN(cc.con_contact)
       FROM TBL_COM_X_SPE cxs
       JOIN TBL_CON_X_COM cxc ON cxc.cxc_company_id = cxs.cxs_company_id
       JOIN TBL_CONTACTS cc   ON cc.con_id = cxc.cxc_contact_id AND cc.con_type = 'EMAIL'
      WHERE cxs.cxs_specialities_id = spe.spe_id) AS speciality_email,

    -- Contexto productor (util para el detalle del correo)
    pro.pro_id,
    per_pro.per_name || ' ' || per_pro.per_lastname AS producer_name,
    (SELECT MIN(cp.con_contact)
       FROM TBL_PER_X_CON pxp
       JOIN TBL_CONTACTS cp ON cp.con_id = pxp.pxc_contact_id AND cp.con_type = 'EMAIL'
      WHERE pxp.pxc_person_id = per_pro.per_id) AS producer_email,
    (SELECT MIN(ct.con_contact)
       FROM TBL_PER_X_CON pxp2
       JOIN TBL_CONTACTS ct ON ct.con_id = pxp2.pxc_contact_id AND ct.con_type IN ('TELÉFONO','CELULAR')
      WHERE pxp2.pxc_person_id = per_pro.per_id) AS producer_phone,

    -- Decision de destinatario: priorizar email del agronomo, si no, el de la especialidad
    COALESCE(
        (SELECT MIN(ca2.con_contact)
           FROM TBL_PER_X_CON pca2
           JOIN TBL_CONTACTS ca2 ON ca2.con_id = pca2.pxc_contact_id AND ca2.con_type = 'EMAIL'
          WHERE pca2.pxc_person_id = per_agr.per_id),
        (SELECT MIN(cc2.con_contact)
           FROM TBL_COM_X_SPE cxs2
           JOIN TBL_CON_X_COM cxc2 ON cxc2.cxc_company_id = cxs2.cxs_company_id
           JOIN TBL_CONTACTS cc2   ON cc2.con_id = cxc2.cxc_contact_id AND cc2.con_type = 'EMAIL'
          WHERE cxs2.cxs_specialities_id = spe.spe_id)
    ) AS recipient_email

FROM TBL_VISITS v
JOIN TBL_AVAILABILITIES a
  ON a.ava_id = v.vis_available_id
LEFT JOIN TBL_SCHEDULE_AGRONOMISTS sca
  ON sca.sca_id = a.ava_schedule_agronomist_id
LEFT JOIN TBL_SCHEDULE_SPECIALITIES scs
  ON scs.scs_id = a.ava_schedule_specialite_id
LEFT JOIN TBL_AGRONOMISTS agr
  ON agr.agr_id = sca.sca_agronomist_id
LEFT JOIN TBL_PERSON per_agr
  ON per_agr.per_id = agr.agr_person_id
LEFT JOIN TBL_SPECIALITIES spe
  ON spe.spe_id = scs.scs_specialite_id
JOIN TBL_PRODUCERS pro
  ON pro.pro_id = v.vis_producer_id
JOIN TBL_PERSON per_pro
  ON per_pro.per_id = pro.pro_person_id
WHERE a.ava_available = 'OCUPADO'
  AND TRUNC(COALESCE(CAST(sca.sca_date AS DATE), CAST(scs.scs_date AS DATE))) = TRUNC(SYSDATE) + 1;

-- Instalar y conceder UTL_MAIL si hace falta:
-- @?/rdbms/admin/utlmail.sql
-- @?/rdbms/admin/prvtmail.plb
GRANT EXECUTE ON UTL_MAIL TO <ESQUEMA DE LA HP BD>;
ALTER SYSTEM SET SMTP_OUT_SERVER = 'smtp.gmail.com:25' SCOPE=BOTH;

CREATE OR REPLACE PACKAGE PK_NOTIF AS
  PROCEDURE SEND_DAILY_VISITS(p_test_recipient IN VARCHAR2 DEFAULT NULL);
END PK_NOTIF;
/

CREATE OR REPLACE PACKAGE BODY PK_NOTIF AS

  FUNCTION fmt_hour(p_h NUMBER) RETURN VARCHAR2 IS
  BEGIN
    -- p_h es 0..23, lo formateamos HH24:MI
    RETURN LPAD(TRUNC(p_h),2,'0') || ':00';
  END;

  PROCEDURE SEND_ONE_EMAIL(
    p_to    IN VARCHAR2,
    p_rows  IN SYS_REFCURSOR
  ) IS
    v_body   CLOB := 'Estimado(a),'||CHR(10)||
                     'Este es el resumen de sus visitas técnicas programadas para mañana.'||CHR(10)||CHR(10)||
                     'Detalle:'||CHR(10)||
                     '------------------------------------------------------------'||CHR(10);
    v_vis_id           NUMBER;
    v_slots            NUMBER;
    v_start_h          NUMBER;
    v_end_h            NUMBER;
    v_agronomist_name  VARCHAR2(200);
    v_speciality_name  VARCHAR2(200);
    v_producer_name    VARCHAR2(200);
    v_producer_email   VARCHAR2(200);
    v_producer_phone   VARCHAR2(200);
  BEGIN
    LOOP
      FETCH p_rows INTO
        v_vis_id, v_slots, v_start_h, v_end_h,
        v_agronomist_name, v_speciality_name,
        v_producer_name, v_producer_email, v_producer_phone;
      EXIT WHEN p_rows%NOTFOUND;

      v_body := v_body ||
        '- Visita #'||v_vis_id||
        ' | Productor: '||NVL(v_producer_name,'(N/D)')||
        CASE WHEN v_producer_email IS NOT NULL THEN ' | Email productor: '||v_producer_email ELSE '' END||
        CASE WHEN v_producer_phone IS NOT NULL THEN ' | Tel: '||v_producer_phone ELSE '' END||CHR(10)||
        '  Agenda: '||fmt_hour(v_start_h)||'–'||fmt_hour(v_end_h)||
        ' | Slots reservados: '||v_slots||
        CASE WHEN v_agronomist_name IS NOT NULL THEN ' | Agrónomo: '||v_agronomist_name ELSE '' END||
        CASE WHEN v_speciality_name IS NOT NULL THEN ' | Especialidad: '||v_speciality_name ELSE '' END||
        CHR(10);
    END LOOP;
    CLOSE p_rows;

    v_body := v_body||CHR(10)||'Saludos,'||CHR(10)||'AgroTech — Agenda automática';
    UTL_MAIL.SEND(
      sender     => 'no-reply@agrotech.local',
      recipients => p_to,
      subject    => 'Visitas técnicas programadas para mañana',
      message    => v_body,
      mime_type  => 'text/plain; charset=UTF-8'
    );
  END;

  PROCEDURE SEND_DAILY_VISITS(p_test_recipient IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    -- 1) Correos distintos (agrónomo o especialidad) para mañana
    FOR r IN (
      SELECT DISTINCT
             NVL(p_test_recipient, recipient_email) AS recipient
      FROM V_VISITS_TOMORROW
      WHERE NVL(p_test_recipient, recipient_email) IS NOT NULL
    ) LOOP
      -- 2) Abrimos cursor con las filas de ese destinatario
      DECLARE
        c SYS_REFCURSOR;
      BEGIN
        OPEN c FOR
          SELECT
            vis_id,
            vis_slots,
            start_hour,
            end_hour,
            agronomist_name,
            speciality_name,
            producer_name,
            producer_email,
            producer_phone
          FROM V_VISITS_TOMORROW
          WHERE NVL(p_test_recipient, recipient_email) = r.recipient
          ORDER BY start_hour, end_hour, vis_id;

        -- 3) Enviamos 1 correo por destinatario
        SEND_ONE_EMAIL(r.recipient, c);
      END;
    END LOOP;
  END;

END PK_NOTIF;
/

BEGIN
  -- Prueba real (usa emails de la vista):
  PK_NOTIF.SEND_DAILY_VISITS;
  -- Prueba a un correo 'de laboratorio' (redirige todo a 1 destinatario):
  -- PK_NOTIF.SEND_DAILY_VISITS('correo_de_prueba@dominio.com');
END;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_SEND_TOMORROW_VISITS',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'PK_NOTIF.SEND_DAILY_VISITS',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=18;BYMINUTE=0;BYSECOND=0;TZ=America/Costa_Rica',
    enabled         => TRUE,
    comments        => 'Envia resumen de visitas del dia siguiente a agronomos/especialidades'
  );
END;
/
