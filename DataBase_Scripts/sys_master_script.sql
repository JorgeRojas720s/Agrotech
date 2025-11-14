--! MANAGER PROFILE
-- For database managers and administrators with elevated privileges
CREATE PROFILE manager_profile LIMIT
  SESSIONS_PER_USER 6
  CPU_PER_SESSION unlimited
  CPU_PER_CALL unlimited
  CONNECT_TIME unlimited
  IDLE_TIME 180             -- 3 hours (maintenance tasks)
  LOGICAL_READS_PER_SESSION unlimited
  LOGICAL_READS_PER_CALL unlimited
  COMPOSITE_LIMIT unlimited
  PRIVATE_SGA 100K          -- Significant memory for DBA operations
  FAILED_LOGIN_ATTEMPTS 2   -- Very strict for admin accounts
  PASSWORD_LIFE_TIME 30
  PASSWORD_REUSE_TIME 540
  PASSWORD_REUSE_MAX 15
  PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 2;

  --! Basic Role
CREATE ROLE basic;
GRANT CONNECT TO basic;
GRANT CREATE SESSION TO basic;

--! Manager Role
CREATE ROLE manager;
GRANT basic TO manager;
GRANT CREATE TABLE TO manager;
GRANT CREATE VIEW TO manager;
GRANT CREATE PROCEDURE TO manager;
GRANT CREATE SEQUENCE TO manager;
GRANT CREATE TRIGGER TO manager;
GRANT CREATE TYPE TO manager;
GRANT CREATE TABLESPACE TO manager;

--! Manager user
CREATE USER db_manager IDENTIFIED BY "Man@gerSecure2024!"
PROFILE manager_profile;
GRANT manager TO db_manager;