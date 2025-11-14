# Installation guide

## Run the Initial Master Script
``` sys_master_script.sql ```
## Connect as the *db_manager* User
``` CONNECT db_manager ```
### Alternatively:
```ALTER SESSION SET CURRENT_SCHEMA = db_manager; ```

## Execute the Master Script as *db_manager*
``` sys_master_script.sql ```

## Reconnect as the SYS User
```CONNECT sys AS SYSDBA;```
### Run the Final Master Script
```sys_final_master_script.sql```