--! AGRONOMIST PROFILE
-- For agricultural professionals working with field data
CREATE PROFILE agronomist_profile LIMIT
  SESSIONS_PER_USER 3
  CPU_PER_SESSION unlimited
  CPU_PER_CALL 5000
  CONNECT_TIME 600          -- 10 hours (field work)
  IDLE_TIME 120             -- 2 hours (may need longer sessions for reports)
  LOGICAL_READS_PER_SESSION unlimited
  LOGICAL_READS_PER_CALL 5000
  COMPOSITE_LIMIT unlimited
  PRIVATE_SGA 25K
  FAILED_LOGIN_ATTEMPTS 4
  PASSWORD_LIFE_TIME 60
  PASSWORD_REUSE_TIME 360
  PASSWORD_REUSE_MAX 8
  PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 5;

--! TECHNICAL PROFILE
-- For technical staff working with environmental and analysis data
CREATE PROFILE technical_profile LIMIT
  SESSIONS_PER_USER 4
  CPU_PER_SESSION unlimited
  CPU_PER_CALL 10000        -- Higher for data processing
  CONNECT_TIME 720          -- 12 hours (data analysis sessions)
  IDLE_TIME 90              -- 1.5 hours
  LOGICAL_READS_PER_SESSION unlimited
  LOGICAL_READS_PER_CALL 10000
  COMPOSITE_LIMIT unlimited
  PRIVATE_SGA 50K           -- More memory for data processing
  FAILED_LOGIN_ATTEMPTS 4
  PASSWORD_LIFE_TIME 75
  PASSWORD_REUSE_TIME 300
  PASSWORD_REUSE_MAX 10
  PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 5;

--! SECRETARY PROFILE
-- For administrative staff managing appointments and contacts
CREATE PROFILE secretary_profile LIMIT
  SESSIONS_PER_USER 2
  CPU_PER_SESSION unlimited
  CPU_PER_CALL 2000
  CONNECT_TIME 480          -- 8 hours (standard work day)
  IDLE_TIME 30              -- 30 minutes (shorter for security)
  LOGICAL_READS_PER_SESSION unlimited
  LOGICAL_READS_PER_CALL 2000
  COMPOSITE_LIMIT unlimited
  PRIVATE_SGA 20K
  FAILED_LOGIN_ATTEMPTS 3   -- Stricter for administrative access
  PASSWORD_LIFE_TIME 45
  PASSWORD_REUSE_TIME 240
  PASSWORD_REUSE_MAX 12
  PASSWORD_VERIFY_FUNCTION ora12c_strong_verify_function
  PASSWORD_LOCK_TIME 1
  PASSWORD_GRACE_TIME 3;

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