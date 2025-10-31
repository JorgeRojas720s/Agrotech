-- Trigger for specialty pricing changes
CREATE OR REPLACE TRIGGER TRG_LOG_SPECIALTY_PRICING
    AFTER UPDATE ON TBL_SPECIALITIES
    FOR EACH ROW
DECLARE
    v_username VARCHAR2(50);
BEGIN
    v_username := USER;
    
    IF :OLD.spe_price != :NEW.spe_price THEN
        INSERT INTO LOG_SPECIALTY_PRICING (
            log_id, spe_id, price_old, price_new,
            username, action
        ) VALUES (
            SEQ_LOG_SPECIALTY_PRICING.NEXTVAL, :OLD.spe_id,
            :OLD.spe_price, :NEW.spe_price, v_username, 'UPDATE'
        );
    END IF;
END;
/