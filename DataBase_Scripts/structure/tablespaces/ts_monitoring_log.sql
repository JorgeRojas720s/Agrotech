CREATE TABLE TS_MONITORING_LOGS (
    log_id NUMBER PRIMARY KEY,
    tablespace_name VARCHAR2(30),
    used_percentage NUMBER(5,2),
    total_mb NUMBER(15,2),
    free_mb NUMBER(15,2),
    check_date DATE DEFAULT SYSDATE,
    alert_sent CHAR(1) DEFAULT 'N'
);

CREATE SEQUENCE ts_monitoring_seq START WITH 1 INCREMENT BY 1;