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