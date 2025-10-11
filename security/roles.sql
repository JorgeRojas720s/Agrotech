create role basic;
grant CONNECT to basic;
grant CREATE SESSION to basic;

create role manager;
grant basic to manager;
grant CREATE TABLE to manager;
grant CREATE VIEW to manager;
grant CREATE PROCEDURE to manager;
grant CREATE SEQUENCE to manager;
grant CREATE TRIGGER to manager;
grant CREATE TYPE to manager;

create role agronomist;
grant basic to agronomist;
grant SELECT, INSERT, UPDATE, DELETE on SYS.TBL_AGRONOMISTS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_FIELDS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_CROPS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_PESTICIDES to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_FERTILIZERS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_TREATMENTS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_HARVESTS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_IRRIGATIONS to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_WEATHER to agronomist;
grant SELECT, INSERT, UPDATE, DELETE  on SYS.TBL_SOIL_ANALYSES to agronomist;

create role technical;
create role secretary;
