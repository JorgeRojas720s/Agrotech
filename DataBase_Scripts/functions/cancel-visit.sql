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