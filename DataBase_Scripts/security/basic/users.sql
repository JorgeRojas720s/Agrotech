-- SYSBDA's
create user reds IDENTIFIED by reds;
grant sys to reds;
grant basic to reds;

create user fabiux IDENTIFIED by fabiux;
grant sys to fabiux;
grant basic to fabiux;

create user yzma IDENTIFIED by yzma;
grant sys to yzma;
grant basic to yzma;

--! Agronomist user example
CREATE USER agronomist_maria IDENTIFIED BY "AgroSecure2024!"
PROFILE agronomist_profile
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 200M ON users;

GRANT agronomist TO agronomist_maria;

--! Technical user example
CREATE USER tech_carlos IDENTIFIED BY "TechAnalyst2024!"
PROFILE technical_profile
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 500M ON users;  -- More space for technical data

GRANT technical TO tech_carlos;

--! Secretary user example
CREATE USER secretary_ana IDENTIFIED BY "AdminSecure2024!"
PROFILE secretary_profile
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100M ON users;

GRANT secretary TO secretary_ana;

--! Manager user example
CREATE USER db_manager IDENTIFIED BY "ManagerSecure2024!"
PROFILE manager_profile
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA unlimited ON users;

GRANT manager TO db_manager;