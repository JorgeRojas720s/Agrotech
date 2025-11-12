PROMPT 
PROMPT ==================== FASE 2: TABLESPACES ====================

PROMPT 3.1 Tablespace: MASTER_DATA...
@&BASE_PATH/structure/tablespaces/master_data/master_data.sql
@&BASE_PATH/structure/tablespaces/master_data/index.sql

PROMPT 3.2 Tablespace: CATALOGS...
@&BASE_PATH/structure/tablespaces/catalogs/catalogs.sql
@&BASE_PATH/structure/tablespaces/catalogs/index.sql

PROMPT 3.3 Tablespace: FINANCE...
@&BASE_PATH/structure/tablespaces/finance/finance.sql
@&BASE_PATH/structure/tablespaces/finance/index.sql

PROMPT 3.4 Tablespace: AGRICULTURAL_OPERATIONS...
@&BASE_PATH/structure/tablespaces/agricultural_operations/agricultural_operations.sql
@&BASE_PATH/structure/tablespaces/agricultural_operations/index.sql

PROMPT 3.5 Tablespace: PEST_TREATMENTS...
@&BASE_PATH/structure/tablespaces/pest_treatments/pest_treatments.sql
@&BASE_PATH/structure/tablespaces/pest_treatments/index.sql

PROMPT 3.6 Tablespace: SCHEDULING_APPOINTMENTS...
@&BASE_PATH/structure/tablespaces/scheduling_appointments/scheduling_appointments.sql
@&BASE_PATH/structure/tablespaces/scheduling_appointments/index.sql

PROMPT 3.7 Tablespace: TECHNICAL_ENVIRONMENTAL...
@&BASE_PATH/structure/tablespaces/technical_environmental/technical_enviromental.sql
@&BASE_PATH/structure/tablespaces/technical_environmental/index.sql

PROMPT 3.10 Verificando tablespaces...
@&BASE_PATH/structure/tablespaces/verify_tablespaces.sql