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
    -- Fecha de la visita (se toma la fecha de agenda del agronomo si existe, si no la de la especialidad)
    TRUNC(COALESCE(CAST(sca.sca_date AS DATE), CAST(scs.scs_date AS DATE))) AS visit_date,
    -- Ventana horaria (si no hay una de las dos, se muestra la disponible)
    COALESCE(sca.sca_start_time, scs.scs_start_time) AS start_hour,
    COALESCE(sca.sca_end_time,   scs.scs_end_time)   AS end_hour,

    -- Contexto agronomo
    agr.agr_id,
    per_agr.per_name || ' ' || per_agr.per_lastname AS agronomist_name,
    -- Un email del agronomo (si tiene varios, se toma el primero alfabetico)
    (SELECT MIN(ca.con_contact)
       FROM TBL_PER_X_CON pca
       JOIN TBL_CONTACTS ca ON ca.con_id = pca.pxc_contact_id AND ca.con_type = 'EMAIL'
      WHERE pca.pxc_person_id = per_agr.per_id) AS agronomist_email,

    -- Contexto especialidad
    spe.spe_id,
    spe.spe_type AS speciality_name,
    -- Un email 'de la especialidad' (se toma un email de la empresa que ofrece esa especialidad)
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
                     'Este es el resumen de sus visitas tecnicas programadas para maniana.'||CHR(10)||CHR(10)||
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
        CASE WHEN v_agronomist_name IS NOT NULL THEN ' | Agronomo: '||v_agronomist_name ELSE '' END||
        CASE WHEN v_speciality_name IS NOT NULL THEN ' | Especialidad: '||v_speciality_name ELSE '' END||
        CHR(10);
    END LOOP;
    CLOSE p_rows;

    v_body := v_body||CHR(10)||'Saludos,'||CHR(10)||'AgroTech — Agenda automatica';
    UTL_MAIL.SEND(
      sender     => 'no-reply@agrotech.local',
      recipients => p_to,
      subject    => 'Visitas tecnicas programadas para maniana',
      message    => v_body,
      mime_type  => 'text/plain; charset=UTF-8'
    );
  END;

  PROCEDURE SEND_DAILY_VISITS(p_test_recipient IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    -- 1) Correos distintos (agronomo o especialidad) para maniana
    FOR r IN (
      SELECT DISTINCT
             NVL(p_test_recipient, recipient_email) AS recipient
      FROM V_VISITS_TOMORROW
      WHERE NVL(p_test_recipient, recipient_email) IS NOT NULL
    ) LOOP
      -- 2) Abrir cursor con las filas de ese destinatario
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

        -- 3) Envia 1 correo por destinatario
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

-- Si no se logra de esta forma, podemos preguntar por hacer una tabla EMAILS_LOG
-- para guardarlos ahi nada mas

-- =========================================
-- Un dia antes de la visita asignada debe de enviarse un correo notificandole al
-- productor sobre la visita tecnica.
-- =========================================

-- FALTAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!!!!!!!!!!!!!!!!!!!!!

-- =========================================
-- Cada vez que se incluya una inspeccion nueva si contiene
-- datos nuevos deben de actualizarse en el expediente tecnico.
-- =========================================
CREATE OR REPLACE TRIGGER TRG_FIELD_INSPECTION_UPDATE_TEF
AFTER INSERT ON TBL_FIELD_INSPECTIONS
FOR EACH ROW
DECLARE
    v_technical_file_id   NUMBER;
    v_environmental_id    NUMBER;
    v_prev_ph             NUMBER;
    v_prev_humidity       NUMBER;
    v_prev_temp           NUMBER;
    v_prev_nutrients      VARCHAR2(25);
BEGIN
    -- 1) Localizar el expediente tecnico asociado al cultivo inspeccionado
    SELECT tef.tef_id
      INTO v_technical_file_id
      FROM TBL_TECHNICAL_FILES tef
      JOIN TBL_HISTORY_CROPS hic ON hic.hic_id = tef.tef_history_crops_id
      JOIN TBL_FARMS far ON far.far_id = hic.hic_farm_id
      JOIN TBL_PRODUCERS pro ON pro.pro_farm_id = far.far_id
      JOIN TBL_CROPS cro ON cro.cro_id = :NEW.fii_crops_id
     WHERE ROWNUM = 1;

    -- 2) Buscar los ultimos datos ambientales de ese expediente
    BEGIN
        SELECT end_id
          INTO v_environmental_id
          FROM TBL_ENVIRONMENTALS_DATA
         WHERE end_technical_files_id = v_technical_file_id
         ORDER BY end_date DESC
         FETCH FIRST 1 ROWS ONLY;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_environmental_id := NULL;
    END;

    -- 3) Si no hay datos previos, registrar uno nuevo directamente
    IF v_environmental_id IS NULL THEN
        INSERT INTO TBL_ENVIRONMENTALS_DATA (
            end_id, end_technical_files_id, end_date
        ) VALUES (
            SEQ_ENVIRONMENTALS_DATA.NEXTVAL, v_technical_file_id, SYSTIMESTAMP
        );
        DBMS_OUTPUT.PUT_LINE('Se creo registro ambiental inicial para el expediente ' || v_technical_file_id);
        RETURN;
    END IF;

    -- 4) Comparar datos previos (simulacion de lectura)
    BEGIN
        SELECT clc.clc_environmental_data_id, soi.sot_crops_id
          INTO v_prev_ph, v_prev_humidity
          FROM TBL_CLIMATIC_CONDITIONS clc
          JOIN TBL_SOILS_TYPE soi ON soi.sot_environmental_data_id = clc.clc_environmental_data_id
         WHERE clc.clc_environmental_data_id = v_environmental_id
           AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_prev_ph := NULL;
            v_prev_humidity := NULL;
    END;

    -- 5) Si hay diferencias, insertar un nuevo registro ambiental actualizado
    IF NVL(v_prev_ph, -1) <> NVL(:NEW.fii_soil_ph, -1)
       OR NVL(v_prev_humidity, -1) <> NVL(:NEW.fii_humidity, -1)
       OR NVL(v_prev_temp, -1) <> NVL(:NEW.fii_ambient_temperature, -1)
       OR NVL(v_prev_nutrients, 'X') <> NVL(:NEW.fii_nutrient_level, 'X') THEN

        INSERT INTO TBL_ENVIRONMENTALS_DATA (
            end_id,
            end_technical_files_id,
            end_date
        ) VALUES (
            SEQ_ENVIRONMENTALS_DATA.NEXTVAL,
            v_technical_file_id,
            SYSTIMESTAMP
        );

        DBMS_OUTPUT.PUT_LINE('Se actualizo expediente tecnico ' || v_technical_file_id || ' con nuevos datos ambientales.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ℹInspeccion sin cambios relevantes, no se actualiza expediente.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontro expediente tecnico asociado al cultivo ' || :NEW.fii_crops_id);
END;
/

-- Inserto una inspeccion
INSERT INTO TBL_FIELD_INSPECTIONS
(fii_id, fii_soil_ph, fii_humidity, fii_ambient_temperature, fii_nutrient_level, fii_crops_id, fii_agronomists_id)
VALUES (SEQ_FIELD_INSPECTIONS.NEXTVAL, 6.8, 78, 26.5, 'MEDIO', 10, 2);

-- =========================================
-- Cada plaga o enfermedad tiene un impacto diferente para SENASA, por
-- ejemplo, plagas cuarentenarias que son altamente destructivas por ejemplo el
-- HLB de los citricos, se solicita que en el momento que se detecte esta plaga
-- en una finca deben de trasladar la informacion del productor a una tabla
-- especial, la cual sera trasladada periodicamente a SENASA, esta tabla debe
-- de estar totalmente encriptada, ya que su informacion es sumamente
-- delicada y privada.
-- =========================================
-- Impacto SENASA para plagas
ALTER TABLE TBL_PESTS ADD (pes_senasa_impact VARCHAR2(20));
ALTER TABLE TBL_PESTS
  ADD CONSTRAINT CHK_PES_IMPACT CHECK (pes_senasa_impact IN
    ('CUARENTENARIA','CRITICA','ALTA','MEDIA','BAJA','NINGUNA'));

-- Impacto SENASA para enfermedades
ALTER TABLE TBL_DISEASES ADD (dis_senasa_impact VARCHAR2(20));
ALTER TABLE TBL_DISEASES
  ADD CONSTRAINT CHK_DIS_IMPACT CHECK (dis_senasa_impact IN
    ('CUARENTENARIA','CRITICA','ALTA','MEDIA','BAJA','NINGUNA'));

CREATE TABLE TBL_SENASA_CASES_ENC (
  sca_id               NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
  sca_created_at       TIMESTAMP DEFAULT SYSTIMESTAMP,
  sca_type             VARCHAR2(10)  CHECK (sca_type IN ('PEST','DISEASE')),
  sca_entity_id        NUMBER NOT NULL,       -- pest_id o disease_id
  sca_farm_id          NUMBER NOT NULL,       -- far_id
  sca_producer_id      NUMBER NOT NULL,       -- pro_id

  -- Encriptados (AES-256):
  sca_producer_name    RAW(2000),
  sca_producer_idnum   RAW(2000),
  sca_producer_email   RAW(2000),
  sca_producer_phone   RAW(2000),
  sca_farm_address     RAW(2000),

  -- IV por fila
  sca_iv               RAW(16)
);

CREATE OR REPLACE PACKAGE PK_CRYPTO AS
  FUNCTION get_key RETURN RAW; -- Obtiene la clave AES-256 (32 bytes)
  FUNCTION random_iv RETURN RAW; -- 16 bytes

  FUNCTION enc_varchar2(p_plain IN VARCHAR2, p_iv IN RAW) RETURN RAW;
  FUNCTION dec_varchar2(p_cipher IN RAW, p_iv IN RAW) RETURN VARCHAR2;
END PK_CRYPTO;
/

CREATE OR REPLACE PACKAGE BODY PK_CRYPTO AS
  -- Clave constante de demo (32 bytes)
  g_demo_key CONSTANT RAW(32) :=
    hextoraw('00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF');

  FUNCTION get_key RETURN RAW IS
    v_key RAW(32);
  BEGIN
    v_key := g_demo_key;
    RETURN v_key;
  END;

  FUNCTION random_iv RETURN RAW IS
    v_iv RAW(16);
  BEGIN
    v_iv := DBMS_CRYPTO.RANDOMBYTES(16);
    RETURN v_iv;
  END;

  FUNCTION enc_varchar2(p_plain IN VARCHAR2, p_iv IN RAW) RETURN RAW IS
    v_key RAW(32) := get_key();
  BEGIN
    IF p_plain IS NULL THEN RETURN NULL; END IF;
    RETURN DBMS_CRYPTO.ENCRYPT(
             src => UTL_I18N.STRING_TO_RAW(p_plain, 'AL32UTF8'),
             typ => DBMS_CRYPTO.AES_CBC_PKCS5,
             key => v_key,
             iv  => p_iv
           );
  END;

  FUNCTION dec_varchar2(p_cipher IN RAW, p_iv IN RAW) RETURN VARCHAR2 IS
    v_key RAW(32) := get_key();
    v_raw RAW(32767);
  BEGIN
    IF p_cipher IS NULL THEN RETURN NULL; END IF;
    v_raw := DBMS_CRYPTO.DECRYPT(
               src => p_cipher,
               typ => DBMS_CRYPTO.AES_CBC_PKCS5,
               key => v_key,
               iv  => p_iv
             );
    RETURN UTL_I18N.RAW_TO_CHAR(v_raw, 'AL32UTF8');
  END;
END PK_CRYPTO;
/

CREATE OR REPLACE PACKAGE PK_SENASA AS
  PROCEDURE capture_pest_case(p_farm_id IN NUMBER, p_pest_id IN NUMBER);
  PROCEDURE capture_disease_case(p_farm_id IN NUMBER, p_disease_id IN NUMBER);
END PK_SENASA;
/

CREATE OR REPLACE PACKAGE BODY PK_SENASA AS

  FUNCTION first_email_for_person(p_person_id NUMBER) RETURN VARCHAR2 IS
    v_email VARCHAR2(200);
  BEGIN
    SELECT MIN(c.con_contact)
      INTO v_email
      FROM TBL_PER_X_CON px
      JOIN TBL_CONTACTS c ON c.con_id = px.pxc_contact_id AND c.con_type = 'EMAIL'
     WHERE px.pxc_person_id = p_person_id;
    RETURN v_email;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END;

  FUNCTION first_phone_for_person(p_person_id NUMBER) RETURN VARCHAR2 IS
    v_tel VARCHAR2(200);
  BEGIN
    SELECT MIN(c.con_contact)
      INTO v_tel
      FROM TBL_PER_X_CON px
      JOIN TBL_CONTACTS c ON c.con_id = px.pxc_contact_id AND c.con_type IN ('TELEFONO','CELULAR')
     WHERE px.pxc_person_id = p_person_id;
    RETURN v_tel;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END;

  FUNCTION farm_address_text(p_farm_id NUMBER) RETURN VARCHAR2 IS
    v_addr VARCHAR2(1000);
  BEGIN
    SELECT add_country||'/'||add_province||'/'||add_canton||'/'||add_district||'/'||
           NVL(add_community,'')||' - '||NVL(add_address,'')
      INTO v_addr
      FROM TBL_FARMS f
      JOIN TBL_ADDRESS a ON a.add_id = f.far_address_id
     WHERE f.far_id = p_farm_id;
    RETURN v_addr;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
  END;

  PROCEDURE do_insert_enc(
    p_type      IN VARCHAR2,  -- 'PEST' | 'DISEASE'
    p_entity_id IN NUMBER,
    p_farm_id   IN NUMBER
  ) IS
    v_pro_id    NUMBER;
    v_per_id    NUMBER;
    v_name      VARCHAR2(200);
    v_idnum     VARCHAR2(50);
    v_email     VARCHAR2(200);
    v_phone     VARCHAR2(200);
    v_addr      VARCHAR2(1000);
    v_iv        RAW(16);
  BEGIN
    -- 1) productor de la finca
    SELECT pro.pro_id, per.per_id, per.per_name||' '||per.per_lastname, per.per_identification
      INTO v_pro_id, v_per_id, v_name, v_idnum
      FROM TBL_PRODUCERS pro
      JOIN TBL_PERSON per ON per.per_id = pro.pro_person_id
     WHERE pro.pro_farm_id = p_farm_id
       AND pro.pro_active = 'S'
       FETCH FIRST 1 ROWS ONLY;

    -- 2) contactos y direccion
    v_email := first_email_for_person(v_per_id);
    v_phone := first_phone_for_person(v_per_id);
    v_addr  := farm_address_text(p_farm_id);

    -- 3) cifrar e insertar
    v_iv := PK_CRYPTO.random_iv();

    INSERT INTO TBL_SENASA_CASES_ENC(
      sca_type, sca_entity_id, sca_farm_id, sca_producer_id,
      sca_producer_name, sca_producer_idnum, sca_producer_email, sca_producer_phone, sca_farm_address,
      sca_iv
    ) VALUES (
      p_type, p_entity_id, p_farm_id, v_pro_id,
      PK_CRYPTO.enc_varchar2(v_name,  v_iv),
      PK_CRYPTO.enc_varchar2(v_idnum, v_iv),
      PK_CRYPTO.enc_varchar2(v_email, v_iv),
      PK_CRYPTO.enc_varchar2(v_phone, v_iv),
      PK_CRYPTO.enc_varchar2(v_addr,  v_iv),
      v_iv
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- No hay productor activo para esa finca; registramos igual el caso con datos minimos?
      NULL; -- o log en tabla de inconsistencias
  END;

  PROCEDURE capture_pest_case(p_farm_id IN NUMBER, p_pest_id IN NUMBER) IS
    v_impact VARCHAR2(20);
  BEGIN
    -- Usa impacto SENASA (o severidad si no agregaste la columna)
    SELECT NVL(pes_senasa_impact, CASE UPPER(pes_severity) WHEN 'CRITICA' THEN 'CRITICA' ELSE 'NINGUNA' END)
      INTO v_impact
      FROM TBL_PESTS
     WHERE pes_id = p_pest_id;

    IF v_impact IN ('CUARENTENARIA','CRITICA') THEN
      do_insert_enc('PEST', p_pest_id, p_farm_id);
    END IF;
  END;

  PROCEDURE capture_disease_case(p_farm_id IN NUMBER, p_disease_id IN NUMBER) IS
    v_impact VARCHAR2(20);
  BEGIN
    SELECT NVL(dis_senasa_impact, CASE UPPER(dis_severity) WHEN 'CRITICA' THEN 'CRITICA' ELSE 'NINGUNA' END)
      INTO v_impact
      FROM TBL_DISEASES
     WHERE dis_id = p_disease_id;

    IF v_impact IN ('CUARENTENARIA','CRITICA') THEN
      do_insert_enc('DISEASE', p_disease_id, p_farm_id);
    END IF;
  END;

END PK_SENASA;
/

-- Plagas en finca
CREATE OR REPLACE TRIGGER TRG_FARM_PESTS_SENASA
AFTER INSERT ON TBL_FARM_X_PESTS
FOR EACH ROW
BEGIN
  PK_SENASA.capture_pest_case(:NEW.fxp_farms_id, :NEW.fxp_pests_id);
END;
/

-- Enfermedades en finca
CREATE OR REPLACE TRIGGER TRG_FARM_DISEASES_SENASA
AFTER INSERT ON TBLS_FAR_X_DIS
FOR EACH ROW
BEGIN
  PK_SENASA.capture_disease_case(:NEW.fxd_farms_id, :NEW.fxd_diseases_id);
END;
/

-- Vista de lectura (solo para rol SENASA_READ)
CREATE OR REPLACE VIEW V_SENASA_CASES_DEC AS
SELECT
  sca_id, sca_created_at, sca_type, sca_entity_id, sca_farm_id, sca_producer_id,
  PK_CRYPTO.dec_varchar2(sca_producer_name,  sca_iv) AS producer_name,
  PK_CRYPTO.dec_varchar2(sca_producer_idnum, sca_iv) AS producer_idnum,
  PK_CRYPTO.dec_varchar2(sca_producer_email, sca_iv) AS producer_email,
  PK_CRYPTO.dec_varchar2(sca_producer_phone, sca_iv) AS producer_phone,
  PK_CRYPTO.dec_varchar2(sca_farm_address,   sca_iv) AS farm_address
FROM TBL_SENASA_CASES_ENC;

-- Solo el rol SENASA_READ puede verla:
-- CREATE ROLE SENASA_READ;
-- GRANT SELECT ON V_SENASA_CASES_DEC TO SENASA_READ;

-- Marca una plaga cuaren­tenaria/critica
UPDATE TBL_PESTS SET pes_senasa_impact = 'CUARENTENARIA' WHERE pes_id = 1;

-- Relaciona la plaga a una finca
INSERT INTO TBL_FARM_X_PESTS (fxp_farms_id, fxp_pests_id) VALUES (10, 1);

-- Debe haber insert en la tabla encriptada
SELECT sca_id, sca_type, sca_entity_id, sca_farm_id, sca_producer_id, sca_iv FROM TBL_SENASA_CASES_ENC;

-- (Si creaste la vista)
SELECT * FROM V_SENASA_CASES_DEC;  -- solo con permisos

