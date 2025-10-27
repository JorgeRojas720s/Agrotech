-- Logbook Table
CREATE TABLE LOG_AGRONOMIC_VISITS (
    log_id NUMBER PRIMARY KEY,
    vis_id NUMBER,
    vis_producer_id NUMBER,
    vis_available_id NUMBER,
    vis_attendance_old CHAR(1),
    vis_attendance_new CHAR(1),
    vis_slots_old NUMBER,
    vis_slots_new NUMBER,
    change_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    username VARCHAR2(50),
    action VARCHAR2(20)
);

-- Sequence for log
CREATE SEQUENCE SEQ_LOG_VISITS START WITH 1 INCREMENT BY 1;