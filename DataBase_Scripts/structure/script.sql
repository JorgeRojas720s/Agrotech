CREATE TABLE TBL_ADDRESS 
    ( 
     add_id        NUMBER  NOT NULL , 
     add_country   VARCHAR2 (30) , 
     add_province  VARCHAR2 (30) , 
     add_canton    VARCHAR2 (30) , 
     add_district  VARCHAR2 (30) , 
     add_community VARCHAR2 (30) , 
     add_address   VARCHAR2 (200) 
    ) 
;

ALTER TABLE TBL_ADDRESS 
    ADD CONSTRAINT TBL_ADDRESS_PK PRIMARY KEY ( add_id ) ;

CREATE TABLE TBL_AGRONOMISTS 
    ( 
     agr_id              NUMBER  NOT NULL , 
     agr_company_id      NUMBER  NOT NULL , 
     agr_person_id       NUMBER  NOT NULL , 
     agr_hiring_date     TIMESTAMP , 
     agr_salary_id       NUMBER  NOT NULL , 
     agr_consult_price NUMBER (12,2), 
     agr_professional_id NUMBER 
    ) 
;

ALTER TABLE TBL_AGRONOMISTS 
    ADD CONSTRAINT TBL_AGRONOMIST_PK PRIMARY KEY ( agr_id ) ;

CREATE TABLE TBL_ANOTATIONS 
    ( 
     ano_id                 NUMBER , 
     ano_technical_files_id NUMBER  NOT NULL , 
     ano_title              VARCHAR2 (40) , 
     ano_anotation          VARCHAR2 (200) , 
     ano_date               TIMESTAMP DEFAULT SYSTIMESTAMP
    ) 
;

CREATE TABLE TBL_AVAILABILITIES 
    ( 
     ava_id                     NUMBER  NOT NULL , 
     ava_schedule_agronomist_id NUMBER  NOT NULL , 
     ava_schedule_specialite_id NUMBER  NOT NULL , 
     ava_available              CHAR (20) 
    ) 
;

ALTER TABLE TBL_AVAILABILITIES 
    ADD CONSTRAINT TBL_AVAILABILITY_PK PRIMARY KEY ( ava_id ) ;

ALTER TABLE TBL_AVAILABILITIES
    ADD CONSTRAINT CHK_AVA_AVAILABLE CHECK (ava_available IN ('CANCELADO', 'DISPONIBLE', 'OCUPADO')); 

CREATE TABLE TBL_CANCELLED_HISTORIES 
    ( 
     cah_id          NUMBER  NOT NULL , 
     cah_availaty_id NUMBER  NOT NULL , 
     cah_visit_id    NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_CANCELLED_HISTORIES 
    ADD CONSTRAINT TBL_CANCELLED_HISTORY_PK PRIMARY KEY ( cah_id ) ;

CREATE TABLE TBL_CERTFICATIONS 
    ( 
     cer_id   NUMBER  NOT NULL , 
     cer_name VARCHAR2 (50) 
    ) 
;

ALTER TABLE TBL_CERTFICATIONS 
    ADD CONSTRAINT TBL_CERTFICATIONS_PK PRIMARY KEY ( cer_id ) ;

CREATE TABLE TBL_CLIMATIC_CONDITIONS 
    ( 
     clc_id                    NUMBER  NOT NULL , 
     clc_environmental_data_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_CLIMATIC_CONDITIONS 
    ADD CONSTRAINT TBL_CLIMATIC_CONDITIONS_PK PRIMARY KEY ( clc_id ) ;

CREATE TABLE TBL_COM_X_SPE 
    ( 
     cxs_company_id      NUMBER  NOT NULL , 
     cxs_specialities_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_COM_X_SPE 
    ADD CONSTRAINT COMPANY_X_SPECIALTIES_PK PRIMARY KEY ( cxs_specialities_id, cxs_company_id ) ;

CREATE TABLE TBL_COMPANIES 
    ( 
     com_id              NUMBER  NOT NULL , 
     com_name            VARCHAR2 (50) , 
     com_owner_id        NUMBER , 
     com_address_id      NUMBER  NOT NULL , 
     com_foundation_date TIMESTAMP
    ) 
;

ALTER TABLE TBL_COMPANIES 
    ADD CONSTRAINT TBL_COMPANY_PK PRIMARY KEY ( com_id ) ;

CREATE TABLE TBL_CON_X_COM 
    ( 
     cxc_company_id NUMBER  NOT NULL , 
     cxc_contact_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_CON_X_COM 
    ADD CONSTRAINT TBL_CON_X_COM_PK PRIMARY KEY ( cxc_company_id, cxc_contact_id ) ;

CREATE TABLE TBL_CONTACTS 
    ( 
     con_id      NUMBER  NOT NULL , 
     con_type    VARCHAR2 (15) , 
     con_contact VARCHAR2 (60) 
    ) 
;

ALTER TABLE TBL_CONTACTS 
    ADD CONSTRAINT TBL_CONTACT_PK PRIMARY KEY ( con_id ) ;

ALTER TABLE TBL_CONTACTS
    ADD CONSTRAINT CHK_CON_TYPE CHECK (con_type IN ('EMAIL', 'TELÉFONO', 'CELULAR', 'FAX', 'OTRO'));

CREATE TABLE TBL_CRO_X_CRT 
    ( 
     cxc_crops_id      NUMBER  NOT NULL , 
     cxc_crops_type_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_CRO_X_CRT 
    ADD CONSTRAINT TBL_CROPS_X_CROPS_TYPE_PK PRIMARY KEY ( cxc_crops_id, cxc_crops_type_id ) ;

CREATE TABLE TBL_CROPS 
    ( 
     cro_id   NUMBER  NOT NULL , 
     cro_age  TIMESTAMP , 
     cro_area NUMBER (12,2) 
    ) 
;

ALTER TABLE TBL_CROPS 
    ADD CONSTRAINT TBL_CROPS_PK PRIMARY KEY ( cro_id ) ;

ALTER TABLE TBL_CROPS
    ADD CONSTRAINT CHK_CRO_AREA CHECK (cro_area > 0);

CREATE TABLE TBL_CROPS_TYPE 
    ( 
     crt_id   NUMBER  NOT NULL , 
     crt_type VARCHAR2 (30) 
    ) 
;

ALTER TABLE TBL_CROPS_TYPE 
    ADD CONSTRAINT TBL_CROPS_TYPE_PK PRIMARY KEY ( crt_id ) ;

CREATE TABLE TBL_DISEASES 
    ( 
     dis_id NUMBER  NOT NULL,
     dis_name VARCHAR2 (50),
     dis_description VARCHAR2 (200),
     dis_severity VARCHAR2 (20)
    ) 
;

ALTER TABLE TBL_DISEASES 
    ADD CONSTRAINT TBL_DISEASES_PK PRIMARY KEY ( dis_id ) ;

ALTER TABLE TBL_DISEASES
    ADD CONSTRAINT CHK_DIS_SEVERITY CHECK (dis_severity IN ('BAJA', 'MEDIA', 'ALTA', 'CRÍTICA'));

CREATE TABLE TBL_END_X_WAS 
    ( 
     exw_environmental_data_id NUMBER  NOT NULL , 
     exw_water_sources_id      NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_END_X_WAS 
    ADD CONSTRAINT TBL_END_X_WAS_PK PRIMARY KEY ( exw_water_sources_id, exw_environmental_data_id ) ;

CREATE TABLE TBL_ENVIRONMENTALS_DATA 
    ( 
     end_id                 NUMBER  NOT NULL , 
     end_technical_files_id NUMBER  NOT NULL ,
     end_date               TIMESTAMP DEFAULT SYSTIMESTAMP
    ) 
;

ALTER TABLE TBL_ENVIRONMENTALS_DATA 
    ADD CONSTRAINT TBL_ENVIRONMENTAL_DATA_PK PRIMARY KEY ( end_id ) ;

CREATE TABLE TBL_FAR_X_CRO 
    ( 
     fxc_farms_id NUMBER  NOT NULL , 
     fxc_crops_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_FAR_X_CRO 
    ADD CONSTRAINT TBL_FARM_X_CROPS_PK PRIMARY KEY ( fxc_crops_id, fxc_farms_id ) ;

CREATE TABLE TBL_FARM_X_PESTS 
    ( 
     fxp_farms_id NUMBER  NOT NULL , 
     fxp_pests_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_FARM_X_PESTS 
    ADD CONSTRAINT TBL_FARM_X_PLAGES_PK PRIMARY KEY ( fxp_pests_id, fxp_farms_id ) ;

CREATE TABLE TBL_FARMS 
    ( 
     far_id            NUMBER  NOT NULL , 
     far_company_id    NUMBER  NOT NULL , 
     far_hectares      NUMBER (12,2) , 
     far_address_id    NUMBER  NOT NULL , 
     far_register_date TIMESTAMP DEFAULT SYSTIMESTAMP
    ) 
;

ALTER TABLE TBL_FARMS 
    ADD CONSTRAINT TBL_FARMS_PK PRIMARY KEY ( far_id ) ;

ALTER TABLE TBL_FARMS
    ADD CONSTRAINT CHK_FAR_HECTARES CHECK (far_hectares > 0);

CREATE TABLE TBL_FIELD_INSPECTIONS 
    ( 
     fii_id                  NUMBER  NOT NULL , 
     fii_soil_ph             NUMBER , 
     fii_humidity            NUMBER , 
     fii_ambient_temperature NUMBER (10,2) , 
     fii_nutrient_level      VARCHAR2 (25) , 
     fii_crops_id            NUMBER  NOT NULL , 
     fii_agronomists_id      NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_FIELD_INSPECTIONS 
    ADD CONSTRAINT TBL_FIELD_INSPECTION_PK PRIMARY KEY ( fii_id ) ;

ALTER TABLE TBL_FIELD_INSPECTIONS
    ADD CONSTRAINT CHK_FII_SOIL_PH CHECK (fii_soil_ph BETWEEN 0 AND 14);

ALTER TABLE TBL_FIELD_INSPECTIONS
    ADD CONSTRAINT CHK_FII_HUMIDITY CHECK (fii_humidity BETWEEN 0 AND 100);

ALTER TABLE TBL_FIELD_INSPECTIONS
    ADD CONSTRAINT CHK_FII_AMBIENT_TEMPERATURE CHECK (fii_ambient_temperature >= -50 AND fii_ambient_temperature <= 60);

CREATE TABLE TBL_HISTORY_CROPS 
    ( 
     hic_id      NUMBER  NOT NULL , 
     hic_farm_id NUMBER  NOT NULL ,
     hic_harvest_date     TIMESTAMP,
     hic_sowing_date     TIMESTAMP 
    ) 
;

ALTER TABLE TBL_HISTORY_CROPS 
    ADD CONSTRAINT TBL_HISTORY_CROPS_PK PRIMARY KEY ( hic_id ) ;

ALTER TABLE TBL_HISTORY_CROPS
    ADD CONSTRAINT CHK_HIC_HARVEST_DATE CHECK (hic_harvest_date >= hic_sowing_date);

CREATE TABLE TBL_LABORATORY_ANALYSIS 
    ( 
     laa_id                 NUMBER  NOT NULL , 
     laa_technical_files_id NUMBER  NOT NULL ,
     laa_analysis_date      TIMESTAMP,
     laa_results            VARCHAR2 (200),
     laa_observations       VARCHAR2 (200)
    ) 
;

ALTER TABLE TBL_LABORATORY_ANALYSIS 
    ADD CONSTRAINT TBL_LABORATORY_ANALYSIS_PK PRIMARY KEY ( laa_id ) ;

CREATE TABLE TBL_NACIONALITIES 
    ( 
     nan_id          NUMBER  NOT NULL , 
     nan_nationality VARCHAR2 (40) 
    ) 
;

ALTER TABLE TBL_NACIONALITIES 
    ADD CONSTRAINT TBL_NACIONALITY_PK PRIMARY KEY ( nan_id ) ;

CREATE TABLE TBL_OCUPATIONS 
    ( 
     ocu_id        NUMBER  NOT NULL , 
     ocu_ocupation VARCHAR2 (40)
    ) 
;

ALTER TABLE TBL_OCUPATIONS 
    ADD CONSTRAINT TBL_OCUPATION_PK PRIMARY KEY ( ocu_id ) ;

CREATE TABLE TBL_PER_X_CON 
    ( 
     pxc_person_id  NUMBER  NOT NULL , 
     pxc_contact_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_PER_X_CON 
    ADD CONSTRAINT TBL_PER_X_CON_PK PRIMARY KEY ( pxc_person_id, pxc_contact_id ) ;

CREATE TABLE TBL_PERSON 
    ( 
     per_id              NUMBER  NOT NULL , 
     per_name            VARCHAR2 (25) , 
     per_lastname        VARCHAR2 (25) , 
     per_identification  VARCHAR2 (25) , 
     per_marital_status  VARCHAR2 (25) , 
     per_gender          CHAR (1) , 
     per_birthday        TIMESTAMP , 
     per_education_level VARCHAR2 (40) , 
     per_nationality_id  NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_PERSON 
    ADD CONSTRAINT TBL_PERSON_PK PRIMARY KEY ( per_id ) ;

ALTER TABLE TBL_PERSON
    ADD CONSTRAINT CHK_GENDER CHECK (per_gender IN ('M', 'F', 'O'));

ALTER TABLE TBL_PERSON
    ADD CONSTRAINT CHK_MARITAL_STATUS CHECK (per_marital_status IN ('SOLTERO/A', 'CASADO/A', 'DIVORCIADO/A', 'VIUDO/A', 'UNIÓN LIBRE'));

ALTER TABLE TBL_PERSON
    ADD CONSTRAINT CHK_EDUCATION_LEVEL CHECK (per_education_level IN ('NINGUNO', 'BÁSICA INCOMPLETA', 'BÁSICA COMPLETA', 'DIVERSIFICADA INCOMPLETA', 'DIVERSIFICADA COMPLETA', 'TÉCNICA INCOMPLETA', 'TÉCNICA COMPLETA', 'UNIVERSITARIA INCOMPLETA', 'UNIVERSITARIA COMPLETA', 'POSTGRADO'));

CREATE TABLE TBL_PESTS 
    ( 
     pes_id NUMBER  NOT NULL,
     pes_name VARCHAR2 (50),
     pes_description VARCHAR2 (200),
     pes_severity VARCHAR2 (20)
    ) 
;

ALTER TABLE TBL_PESTS 
    ADD CONSTRAINT TBL_PESTS_PK PRIMARY KEY ( pes_id ) ;

ALTER TABLE TBL_PESTS
    ADD CONSTRAINT CHK_PES_SEVERITY CHECK (pes_severity IN ('BAJA', 'MEDIA', 'ALTA', 'CRÍTICA'));

CREATE TABLE TBL_PRODUCERS 
    ( 
     pro_id           NUMBER  NOT NULL , 
     pro_person_id    NUMBER  NOT NULL , 
     pro_farm_id      NUMBER  NOT NULL , 
     pro_ocupation_id NUMBER  NOT NULL ,
     pro_registration_date TIMESTAMP DEFAULT SYSTIMESTAMP,
     pro_active       CHAR (1)
    ) 
;

ALTER TABLE TBL_PRODUCERS 
    ADD CONSTRAINT TBL_PRODUCER_PK PRIMARY KEY ( pro_id ) ;

ALTER TABLE TBL_PRODUCERS
    ADD CONSTRAINT CHK_PRO_ACTIVE CHECK (pro_active IN ('S', 'N'));

ALTER TABLE TBL_PRODUCERS
    ADD CONSTRAINT UQ_PRO_PERSON_FARM UNIQUE (pro_person_id, pro_farm_id);

CREATE TABLE TBL_SALARIES 
    ( 
     sal_id     NUMBER  NOT NULL , 
     sal_amount NUMBER (15,2) 
    ) 
;

ALTER TABLE TBL_SALARIES 
    ADD CONSTRAINT TBL_SALARIES_PK PRIMARY KEY ( sal_id ) ;

ALTER TABLE TBL_SALARIES
    ADD CONSTRAINT CHK_SAL_AMOUNT CHECK (sal_amount > 0);

CREATE TABLE TBL_SCHEDULE_AGRONOMISTS 
    ( 
     sca_id            NUMBER  NOT NULL , 
     sca_agronomist_id NUMBER  NOT NULL , 
     sca_date          TIMESTAMP , 
     sca_start_time    NUMBER (3) , 
     sca_end_time      NUMBER (3) , 
     sca_visit_time    NUMBER (7) 
    ) 
;

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS 
    ADD CONSTRAINT TBL_SCHEDULE_AGRONOMIST_PK PRIMARY KEY ( sca_id ) ;

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS
    ADD CONSTRAINT CHK_SCA_START_TIME CHECK (sca_start_time BETWEEN 0 AND 23);

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS
    ADD CONSTRAINT CHK_SCA_END_TIME CHECK (sca_end_time BETWEEN 0 AND 23);

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS
    ADD CONSTRAINT CHK_SCA_TIME CHECK (sca_end_time > sca_start_time);

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS
    ADD CONSTRAINT CHK_SCA_VISIT_TIME CHECK (sca_visit_time IN (10, 15, 20, 30, 60));

CREATE TABLE TBL_SCHEDULE_SPECIALITIES 
    ( 
     scs_id            NUMBER  NOT NULL , 
     scs_specialite_id NUMBER  NOT NULL , 
     scs_date          TIMESTAMP , 
     scs_start_time    NUMBER (3) , 
     scs_end_time      NUMBER (3) , 
     scs_visit_time    NUMBER (7) 
    ) 
;

ALTER TABLE TBL_SCHEDULE_SPECIALITIES 
    ADD CONSTRAINT TBL_SCHEDULE_SPECIALITE_PK PRIMARY KEY ( scs_id ) ;

ALTER TABLE TBL_SCHEDULE_SPECIALITIES
    ADD CONSTRAINT CHK_SCS_START_TIME CHECK (scs_start_time BETWEEN 0 AND 23);

ALTER TABLE TBL_SCHEDULE_SPECIALITIES
    ADD CONSTRAINT CHK_SCS_END_TIME CHECK (scs_end_time BETWEEN 0 AND 23);

ALTER TABLE TBL_SCHEDULE_SPECIALITIES
    ADD CONSTRAINT CHK_SCS_TIME CHECK (scs_end_time > scs_start_time);

ALTER TABLE TBL_SCHEDULE_SPECIALITIES
    ADD CONSTRAINT CHK_SCS_VISIT_TIME CHECK (scs_visit_time IN (10, 15, 20, 30, 60));

CREATE TABLE TBL_SOILS 
    ( 
     soi_id                    NUMBER  NOT NULL , 
     soi_name                  VARCHAR2 (50) 
    )
;
ALTER TABLE TBL_SOILS 
    ADD CONSTRAINT TBL_SOILS_PK PRIMARY KEY ( soi_id ) ;

CREATE TABLE TBL_SOILS_TYPE 
    ( 
     sot_id                    NUMBER  NOT NULL , 
     sot_environmental_data_id NUMBER  NOT NULL , 
     sot_crops_id              NUMBER  NOT NULL ,
     sot_type_id               NUMBER  NOT NULL --!AGREGAR FOREIGN KEY A TBL_SOILS
    ) 
;

ALTER TABLE TBL_SOILS_TYPE 
    ADD CONSTRAINT TBL_SOIL_TYPE_PK PRIMARY KEY ( sot_id ) ;

CREATE TABLE TBL_SPECIALITIES 
    ( 
     spe_id          NUMBER  NOT NULL , 
     spe_type        VARCHAR2 (30) , 
     spe_description VARCHAR2 (200),
     spe_price NUMBER (12,2)
    ) 
;

ALTER TABLE TBL_SPECIALITIES 
    ADD CONSTRAINT TBL_SPECIALITIES_PK PRIMARY KEY ( spe_id ) ;

CREATE TABLE TBL_TECHNICAL_FILES 
    ( 
     tef_id               NUMBER  NOT NULL , 
     tef_history_crops_id NUMBER  NOT NULL ,
     tef_creation_date    TIMESTAMP DEFAULT SYSTIMESTAMP,
     tef_objective       VARCHAR2 (200),
     tef_conclusions     VARCHAR2 (200),
     tef_recommendations VARCHAR2 (200)
    ) 
;

ALTER TABLE TBL_TECHNICAL_FILES 
    ADD CONSTRAINT TBL_TECHNICAL_FILE_PK PRIMARY KEY ( tef_id ) ;

CREATE TABLE TBL_TEF_X_CER 
    ( 
     txc_technical_files_id NUMBER  NOT NULL , 
     txc_certifications_id  NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_TEF_X_CER 
    ADD CONSTRAINT TBL_TEF_X_CER_PK PRIMARY KEY ( txc_technical_files_id, txc_certifications_id ) ;

CREATE TABLE TBL_TEF_X_FAR 
    ( 
     txf_technical_files_id NUMBER  NOT NULL , 
     txf_farms_id           NUMBER  NOT NULL , 
     txf_distance           NUMBER (15,2) 
    ) 
;

ALTER TABLE TBL_TEF_X_FAR 
    ADD CONSTRAINT TBL_TEF_X_FAR_PK PRIMARY KEY ( txf_farms_id, txf_technical_files_id ) ;

CREATE TABLE TBL_TEF_X_TRE 
    ( 
     txt_technical_file_id NUMBER  NOT NULL , 
     txt_treatments_id     NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_TEF_X_TRE 
    ADD CONSTRAINT TBL_TEF_X_TRE_PK PRIMARY KEY ( txt_technical_file_id, txt_treatments_id ) ;

CREATE TABLE TBL_TREATMENTS 
    ( 
     tre_id                NUMBER  NOT NULL , 
     tre_treatment_type_id NUMBER  NOT NULL , 
     tre_name              VARCHAR2 (50) 
    ) 
;

ALTER TABLE TBL_TREATMENTS 
    ADD CONSTRAINT TBL_TREATMENTS_PK PRIMARY KEY ( tre_id ) ;

CREATE TABLE TBL_TREATMENTS_TYPE 
    ( 
     trt_id   NUMBER  NOT NULL , 
     trt_name VARCHAR2 (45) 
    ) 
;

ALTER TABLE TBL_TREATMENTS_TYPE 
    ADD CONSTRAINT TBL_TREATMENTS_TYPE_PK PRIMARY KEY ( trt_id ) ;

CREATE TABLE TBL_VISITS 
    ( 
     vis_id           NUMBER  NOT NULL , 
     vis_producer_id  NUMBER  NOT NULL , 
     vis_slots        NUMBER , 
     vis_attendance   CHAR (1) , 
     vis_available_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_VISITS 
    ADD CONSTRAINT TBL_VISIT_PK PRIMARY KEY ( vis_id ) ;

ALTER TABLE TBL_VISITS
    ADD CONSTRAINT CHK_VIS_ATTENDANCE CHECK (vis_attendance IN ('S', 'N'));

ALTER TABLE TBL_VISITS
    ADD CONSTRAINT CHK_VIS_SLOTS CHECK (vis_slots > 0);

CREATE TABLE TBL_WATER_SOURCES 
    ( 
     was_id NUMBER  NOT NULL ,
     was_type VARCHAR2 (30) ,
     was_description VARCHAR2 (200),
     was_quality VARCHAR2 (20),
     was_quantity VARCHAR2 (20)
    ) 
;

ALTER TABLE TBL_WATER_SOURCES 
    ADD CONSTRAINT TBL_WATER_SOURCES_PK PRIMARY KEY ( was_id ) ;

ALTER TABLE TBL_WATER_SOURCES
    ADD CONSTRAINT CHK_WAS_TYPE CHECK (was_type IN ('POZO', 'RÍO', 'LAGO', 'ACUEDUCTO', 'OTRO'));

ALTER TABLE TBL_WATER_SOURCES
    ADD CONSTRAINT CHK_WAS_QUALITY CHECK (was_quality IN ('BUENA', 'REGULAR', 'MALA'));

ALTER TABLE TBL_WATER_SOURCES
    ADD CONSTRAINT CHK_WAS_QUANTITY CHECK (was_quantity IN ('BAJA', 'MEDIA', 'ALTA'));

CREATE TABLE TBL_FAR_X_DIS 
    ( 
     fxd_farms_id    NUMBER  NOT NULL , 
     fxd_diseases_id NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TBL_FAR_X_DIS 
    ADD CONSTRAINT TBL_FARM_X_DISEASES_PK PRIMARY KEY ( fxd_farms_id, fxd_diseases_id ) 
;

CREATE TABLE TBL_ACCOUNT
    (
        acc_id NUMBER NOT NULL,
        acc_amount NUMBER (12,2),
        acc_state VARCHAR2 (15),
        acc_person_id NUMBER,
        acc_date TIMESTAMP DEFAULT SYSTIMESTAMP
    )
;


ALTER TABLE TBL_ACCOUNT 
    ADD CONSTRAINT TBL_ACCOUNT_PK PRIMARY KEY ( acc_id );


ALTER TABLE TBL_ACCOUNT
    ADD CONSTRAINT CHK_ACC_STATE CHECK (acc_state IN ('CANCELADO','PAGADO'));


CREATE TABLE TBL_COMISSIONS
    (
        com_id NUMBER NOT NULL,
        com_amount NUMBER (12,2),
        com_agronomist_id NUMBER,
        com_date TIMESTAMP DEFAULT SYSTIMESTAMP
    )
;

ALTER TABLE TBL_COMISSIONS 
    ADD CONSTRAINT TBL_COMISSIONS_PK PRIMARY KEY ( com_id );



--!INICIAN LAS FOREIGN KEYS ----------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE TBL_AGRONOMISTS 
    ADD CONSTRAINT FK_AGR_COM FOREIGN KEY 
    ( 
     agr_company_id
    ) 
    REFERENCES TBL_COMPANIES 
    ( 
     com_id
    ) 
;

ALTER TABLE TBL_AGRONOMISTS 
    ADD CONSTRAINT FK_AGR_PER FOREIGN KEY 
    ( 
     agr_person_id
    ) 
    REFERENCES TBL_PERSON 
    ( 
     per_id
    ) 
;

ALTER TABLE TBL_AGRONOMISTS 
    ADD CONSTRAINT FK_AGR_SAL FOREIGN KEY 
    ( 
     agr_salary_id
    ) 
    REFERENCES TBL_SALARIES 
    ( 
     sal_id
    ) 
;

ALTER TABLE TBL_AVAILABILITIES 
    ADD CONSTRAINT FK_AVA_SCA FOREIGN KEY 
    ( 
     ava_schedule_agronomist_id
    ) 
    REFERENCES TBL_SCHEDULE_AGRONOMISTS 
    ( 
     sca_id
    ) 
;

ALTER TABLE TBL_AVAILABILITIES 
    ADD CONSTRAINT FK_AVA_SCS FOREIGN KEY 
    ( 
     ava_schedule_specialite_id
    ) 
    REFERENCES TBL_SCHEDULE_SPECIALITIES 
    ( 
     scs_id
    ) 
;

ALTER TABLE TBL_CANCELLED_HISTORIES 
    ADD CONSTRAINT FK_CAH_AVA FOREIGN KEY 
    ( 
     cah_availaty_id
    ) 
    REFERENCES TBL_AVAILABILITIES 
    ( 
     ava_id
    ) 
;

ALTER TABLE TBL_CANCELLED_HISTORIES 
    ADD CONSTRAINT FK_CAH_VIS FOREIGN KEY 
    ( 
     cah_visit_id
    ) 
    REFERENCES TBL_VISITS 
    ( 
     vis_id
    ) 
;

ALTER TABLE TBL_TEF_X_CER 
    ADD CONSTRAINT FK_CER_X_TEF FOREIGN KEY 
    ( 
     txc_technical_files_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_COMPANIES 
    ADD CONSTRAINT FK_COM_ADD FOREIGN KEY 
    ( 
     com_address_id
    ) 
    REFERENCES TBL_ADDRESS 
    ( 
     add_id
    ) 
;

ALTER TABLE TBL_CON_X_COM 
    ADD CONSTRAINT FK_COM_X_CON FOREIGN KEY 
    ( 
     cxc_company_id
    ) 
    REFERENCES TBL_COMPANIES 
    ( 
     com_id
    ) 
;

ALTER TABLE TBL_COM_X_SPE 
    ADD CONSTRAINT FK_COM_X_SPE FOREIGN KEY 
    ( 
     cxs_company_id
    ) 
    REFERENCES TBL_COMPANIES 
    ( 
     com_id
    ) 
;

ALTER TABLE TBL_CON_X_COM 
    ADD CONSTRAINT FK_CON_X_COM FOREIGN KEY 
    ( 
     cxc_contact_id
    ) 
    REFERENCES TBL_CONTACTS 
    ( 
     con_id
    ) 
;

ALTER TABLE TBL_PER_X_CON 
    ADD CONSTRAINT FK_CON_X_PER FOREIGN KEY 
    ( 
     pxc_contact_id
    ) 
    REFERENCES TBL_CONTACTS 
    ( 
     con_id
    ) 
;

ALTER TABLE TBL_SOILS_TYPE 
    ADD CONSTRAINT FK_CRO_SOT FOREIGN KEY 
    ( 
     sot_crops_id
    ) 
    REFERENCES TBL_CROPS 
    ( 
     cro_id
    ) 
;

ALTER TABLE TBL_SOILS_TYPE 
    ADD CONSTRAINT FK_SOT_SOI FOREIGN KEY 
    ( 
     sot_type_id
    ) 
    REFERENCES TBL_SOILS 
    ( 
     soi_id
    )
;

ALTER TABLE TBL_CRO_X_CRT 
    ADD CONSTRAINT FK_CRO_X_CRT FOREIGN KEY 
    ( 
     cxc_crops_id
    ) 
    REFERENCES TBL_CROPS 
    ( 
     cro_id
    ) 
;

ALTER TABLE TBL_FAR_X_CRO 
    ADD CONSTRAINT FK_CRO_X_FAR FOREIGN KEY 
    ( 
     fxc_crops_id
    ) 
    REFERENCES TBL_CROPS 
    ( 
     cro_id
    ) 
;

ALTER TABLE TBL_CRO_X_CRT 
    ADD CONSTRAINT FK_CRT_X_CRO FOREIGN KEY 
    ( 
     cxc_crops_type_id
    ) 
    REFERENCES TBL_CROPS_TYPE 
    ( 
     crt_id
    ) 
;

ALTER TABLE TBL_FAR_X_DIS 
    ADD CONSTRAINT FK_DIS_X_FAR FOREIGN KEY 
    ( 
     fxd_diseases_id
    ) 
    REFERENCES TBL_DISEASES 
    ( 
     dis_id
    ) 
;

ALTER TABLE TBL_CLIMATIC_CONDITIONS 
    ADD CONSTRAINT FK_END_CLC FOREIGN KEY 
    ( 
     clc_environmental_data_id
    ) 
    REFERENCES TBL_ENVIRONMENTALS_DATA 
    ( 
     end_id
    ) 
;

ALTER TABLE TBL_SOILS_TYPE 
    ADD CONSTRAINT FK_END_SOT FOREIGN KEY 
    ( 
     sot_environmental_data_id
    ) 
    REFERENCES TBL_ENVIRONMENTALS_DATA 
    ( 
     end_id
    ) 
;

ALTER TABLE TBL_ENVIRONMENTALS_DATA 
    ADD CONSTRAINT FK_END_TEF FOREIGN KEY 
    ( 
     end_technical_files_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_END_X_WAS 
    ADD CONSTRAINT FK_END_WAS FOREIGN KEY 
    ( 
     exw_environmental_data_id
    ) 
    REFERENCES TBL_ENVIRONMENTALS_DATA 
    ( 
     end_id
    ) 
;

ALTER TABLE TBL_FARMS 
    ADD CONSTRAINT FK_FAR_ADD FOREIGN KEY 
    ( 
     far_address_id
    ) 
    REFERENCES TBL_ADDRESS 
    ( 
     add_id
    ) 
;

ALTER TABLE TBL_FARMS 
    ADD CONSTRAINT FK_FAR_COM FOREIGN KEY 
    ( 
     far_company_id
    ) 
    REFERENCES TBL_COMPANIES 
    ( 
     com_id
    ) 
;

ALTER TABLE TBL_HISTORY_CROPS 
    ADD CONSTRAINT FK_FAR_HIC FOREIGN KEY 
    ( 
     hic_farm_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_TEF_X_FAR 
    ADD CONSTRAINT FK_FAR_TEF FOREIGN KEY 
    ( 
     txf_farms_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_FAR_X_CRO 
    ADD CONSTRAINT FK_FAR_X_CRO FOREIGN KEY 
    ( 
     fxc_farms_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_FAR_X_DIS 
    ADD CONSTRAINT FK_FAR_X_DIS FOREIGN KEY 
    ( 
     fxd_farms_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_FARM_X_PESTS 
    ADD CONSTRAINT FK_FAR_X_PES FOREIGN KEY 
    ( 
     fxp_pests_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_FIELD_INSPECTIONS 
    ADD CONSTRAINT FK_FII_AGR FOREIGN KEY 
    ( 
     fii_agronomists_id
    ) 
    REFERENCES TBL_AGRONOMISTS 
    ( 
     agr_id
    ) 
;

ALTER TABLE TBL_FIELD_INSPECTIONS 
    ADD CONSTRAINT FK_FII_CRO FOREIGN KEY 
    ( 
     fii_crops_id
    ) 
    REFERENCES TBL_CROPS 
    ( 
     cro_id
    ) 
;

ALTER TABLE TBL_LABORATORY_ANALYSIS 
    ADD CONSTRAINT FK_LAA_TEF FOREIGN KEY 
    ( 
     laa_technical_files_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_PERSON 
    ADD CONSTRAINT FK_PER_NAT FOREIGN KEY 
    ( 
     per_nationality_id
    ) 
    REFERENCES TBL_NACIONALITIES 
    ( 
     nan_id
    ) 
;

ALTER TABLE TBL_PER_X_CON 
    ADD CONSTRAINT FK_PER_X_CON FOREIGN KEY 
    ( 
     pxc_person_id
    ) 
    REFERENCES TBL_PERSON 
    ( 
     per_id
    ) 
;

ALTER TABLE TBL_FARM_X_PESTS 
    ADD CONSTRAINT FK_PES_X_FAR FOREIGN KEY 
    ( 
     fxp_pests_id
    ) 
    REFERENCES TBL_PESTS 
    ( 
     pes_id
    ) 
;

ALTER TABLE TBL_PRODUCERS 
    ADD CONSTRAINT FK_PRO_FAR FOREIGN KEY 
    ( 
     pro_farm_id
    ) 
    REFERENCES TBL_FARMS 
    ( 
     far_id
    ) 
;

ALTER TABLE TBL_PRODUCERS 
    ADD CONSTRAINT FK_PRO_OCU FOREIGN KEY 
    ( 
     pro_ocupation_id
    ) 
    REFERENCES TBL_OCUPATIONS 
    ( 
     ocu_id
    ) 
;

ALTER TABLE TBL_PRODUCERS 
    ADD CONSTRAINT FK_PRO_PER FOREIGN KEY 
    ( 
     pro_person_id
    ) 
    REFERENCES TBL_PERSON 
    ( 
     per_id
    ) 
;

ALTER TABLE TBL_SCHEDULE_AGRONOMISTS 
    ADD CONSTRAINT FK_SCA_AGR FOREIGN KEY 
    ( 
     sca_agronomist_id
    ) 
    REFERENCES TBL_AGRONOMISTS 
    ( 
     agr_id
    ) 
;

ALTER TABLE TBL_SCHEDULE_SPECIALITIES 
    ADD CONSTRAINT FK_SCS_SPE FOREIGN KEY 
    ( 
     scs_specialite_id
    ) 
    REFERENCES TBL_SPECIALITIES 
    ( 
     spe_id
    ) 
;

ALTER TABLE TBL_COM_X_SPE 
    ADD CONSTRAINT FK_SPE_X_COM FOREIGN KEY 
    ( 
     cxs_specialities_id
    ) 
    REFERENCES TBL_SPECIALITIES 
    ( 
     spe_id
    ) 
;

ALTER TABLE TBL_ANOTATIONS 
    ADD CONSTRAINT FK_TEF_ANO FOREIGN KEY 
    ( 
     ano_technical_files_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_TECHNICAL_FILES 
    ADD CONSTRAINT FK_TEF_CER FOREIGN KEY 
    ( 
     tef_history_crops_id
    ) 
    REFERENCES TBL_HISTORY_CROPS 
    ( 
     hic_id
    ) 
;

ALTER TABLE TBL_TEF_X_FAR 
    ADD CONSTRAINT FK_TEF_FAR FOREIGN KEY 
    ( 
     txf_technical_files_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_TEF_X_CER 
    ADD CONSTRAINT FK_TEF_X_CER FOREIGN KEY 
    ( 
     txc_certifications_id
    ) 
    REFERENCES TBL_CERTFICATIONS 
    ( 
     cer_id
    ) 
;

ALTER TABLE TBL_TEF_X_TRE 
    ADD CONSTRAINT FK_TEF_X_TRE FOREIGN KEY 
    ( 
     txt_technical_file_id
    ) 
    REFERENCES TBL_TECHNICAL_FILES 
    ( 
     tef_id
    ) 
;

ALTER TABLE TBL_TREATMENTS 
    ADD CONSTRAINT FK_TRE_TRT FOREIGN KEY 
    ( 
     tre_treatment_type_id
    ) 
    REFERENCES TBL_TREATMENTS_TYPE 
    ( 
     trt_id
    ) 
;

ALTER TABLE TBL_TEF_X_TRE 
    ADD CONSTRAINT FK_TRE_X_TEF FOREIGN KEY 
    ( 
     txt_treatments_id
    ) 
    REFERENCES TBL_TREATMENTS 
    ( 
     tre_id
    ) 
;

ALTER TABLE TBL_VISITS 
    ADD CONSTRAINT FK_VIS_AVA FOREIGN KEY 
    ( 
     vis_available_id
    ) 
    REFERENCES TBL_AVAILABILITIES 
    ( 
     ava_id
    ) 
;

ALTER TABLE TBL_VISITS 
    ADD CONSTRAINT FK_VIS_PRO FOREIGN KEY 
    ( 
     vis_producer_id
    ) 
    REFERENCES TBL_PRODUCERS 
    ( 
     pro_id
    ) 
;

ALTER TABLE TBL_END_X_WAS 
    ADD CONSTRAINT FK_WAS_END FOREIGN KEY 
    ( 
     exw_water_sources_id
    ) 
    REFERENCES TBL_WATER_SOURCES 
    ( 
     was_id
    ) 
;

--!Revisar si falla
ALTER TABLE TBL_ACCOUNT 
    ADD CONSTRAINT FK_ACCOUNT FOREIGN KEY 
    ( 
     acc_person_id
    ) 
    REFERENCES TBL_PERSON 
    ( 
     per_id
    ) 
;

ALTER TABLE TBL_COMISSIONS
    ADD CONSTRAINT FK_COMISSION FOREIGN KEY 
    ( 
     com_agronomist_id
    ) 
    REFERENCES TBL_AGRONOMISTS 
    ( 
     agr_id
    ) 
;

