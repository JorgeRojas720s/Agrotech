-- 1. TBL_NACIONALITIES
INSERT INTO TBL_NACIONALITIES (nan_id, nan_nationality) VALUES (1, 'Costarricense');
INSERT INTO TBL_NACIONALITIES (nan_id, nan_nationality) VALUES (2, 'Nicaragüense');
INSERT INTO TBL_NACIONALITIES (nan_id, nan_nationality) VALUES (3, 'Colombiana');
INSERT INTO TBL_NACIONALITIES (nan_id, nan_nationality) VALUES (4, 'Mexicana');

-- 2. TBL_ADDRESS
INSERT INTO TBL_ADDRESS (add_id, add_country, add_province, add_canton, add_district, add_community, add_address) 
VALUES (1, 'Costa Rica', 'Alajuela', 'San Carlos', 'Florencia', 'Centro', '200 metros norte de la escuela');
INSERT INTO TBL_ADDRESS (add_id, add_country, add_province, add_canton, add_district, add_community, add_address) 
VALUES (2, 'Costa Rica', 'Heredia', 'Barva', 'Barva', 'San Pedro', 'Calle 3, Avenida 5');
INSERT INTO TBL_ADDRESS (add_id, add_country, add_province, add_canton, add_district, add_community, add_address) 
VALUES (3, 'Costa Rica', 'Guanacaste', 'Liberia', 'Liberia', 'La Victoria', 'Frente al supermercado');
INSERT INTO TBL_ADDRESS (add_id, add_country, add_province, add_canton, add_district, add_community, add_address) 
VALUES (4, 'Costa Rica', 'Puntarenas', 'Garabito', 'Jacó', 'Jacó', 'Playa Jacó, 100m este');

-- 3. TBL_PERSON
INSERT INTO TBL_PERSON (per_id, per_name, per_lastname, per_identification, per_marital_status, per_gender, per_birthday, per_education_level, per_nationality_id) 
VALUES (1, 'Juan', 'Rodríguez', '1-1234-5678', 'CASADO/A', 'M', TO_DATE('1985-03-15', 'YYYY-MM-DD'), 'UNIVERSITARIA COMPLETA', 1);
INSERT INTO TBL_PERSON (per_id, per_name, per_lastname, per_identification, per_marital_status, per_gender, per_birthday, per_education_level, per_nationality_id) 
VALUES (2, 'María', 'Gutiérrez', '2-2345-6789', 'SOLTERO/A', 'F', TO_DATE('1990-07-22', 'YYYY-MM-DD'), 'TÉCNICA COMPLETA', 1);
INSERT INTO TBL_PERSON (per_id, per_name, per_lastname, per_identification, per_marital_status, per_gender, per_birthday, per_education_level, per_nationality_id) 
VALUES (3, 'Carlos', 'López', '3-3456-7890', 'UNIÓN LIBRE', 'M', TO_DATE('1978-11-30', 'YYYY-MM-DD'), 'DIVERSIFICADA COMPLETA', 2);
INSERT INTO TBL_PERSON (per_id, per_name, per_lastname, per_identification, per_marital_status, per_gender, per_birthday, per_education_level, per_nationality_id) 
VALUES (4, 'Ana', 'Martínez', '4-4567-8901', 'DIVORCIADO/A', 'F', TO_DATE('1982-05-10', 'YYYY-MM-DD'), 'UNIVERSITARIA COMPLETA', 1);

-- 4. TBL_OCUPATIONS
INSERT INTO TBL_OCUPATIONS (ocu_id, ocu_ocupation) VALUES (1, 'Agricultor');
INSERT INTO TBL_OCUPATIONS (ocu_id, ocu_ocupation) VALUES (2, 'Gerente Agrícola');
INSERT INTO TBL_OCUPATIONS (ocu_id, ocu_ocupation) VALUES (3, 'Técnico Agrícola');
INSERT INTO TBL_OCUPATIONS (ocu_id, ocu_ocupation) VALUES (4, 'Administrador');

-- 5. TBL_SALARIES
INSERT INTO TBL_SALARIES (sal_id, sal_amount) VALUES (1, 1500000.00);
INSERT INTO TBL_SALARIES (sal_id, sal_amount) VALUES (2, 1800000.00);
INSERT INTO TBL_SALARIES (sal_id, sal_amount) VALUES (3, 2200000.00);

-- 6. TBL_COMPANIES
INSERT INTO TBL_COMPANIES (com_id, com_name, com_owner_id, com_address_id, com_foundation_date) 
VALUES (1, 'AgroSolutions S.A.', 1, 1, TO_DATE('2010-05-15', 'YYYY-MM-DD'));
INSERT INTO TBL_COMPANIES (com_id, com_name, com_owner_id, com_address_id, com_foundation_date) 
VALUES (2, 'Cultivos Tropicales Ltda.', 3, 2, TO_DATE('2015-08-20', 'YYYY-MM-DD'));

-- 7. TBL_AGRONOMISTS
INSERT INTO TBL_AGRONOMISTS (agr_id, agr_company_id, agr_person_id, agr_hiring_date, agr_salary_id, agr_consult_price, agr_professional_id) 
VALUES (1, 1, 2, TO_DATE('2023-01-15', 'YYYY-MM-DD'), 2, 50000.00, 1001);
INSERT INTO TBL_AGRONOMISTS (agr_id, agr_company_id, agr_person_id, agr_hiring_date, agr_salary_id, agr_consult_price, agr_professional_id) 
VALUES (2, 2, 4, TO_DATE('2024-03-01', 'YYYY-MM-DD'), 3, 45000.00, 1002);

-- 8. TBL_SPECIALITIES
INSERT INTO TBL_SPECIALITIES (spe_id, spe_type, spe_description, spe_price) 
VALUES (1, 'Suelos', 'Análisis y mejora de suelos agrícolas', 75000.00);
INSERT INTO TBL_SPECIALITIES (spe_id, spe_type, spe_description, spe_price) 
VALUES (2, 'Riego', 'Sistemas de irrigación y manejo hídrico', 65000.00);
INSERT INTO TBL_SPECIALITIES (spe_id, spe_type, spe_description, spe_price) 
VALUES (3, 'Plagas', 'Control integrado de plagas', 80000.00);

-- 9. TBL_COM_X_SPE
INSERT INTO TBL_COM_X_SPE (cxs_company_id, cxs_specialities_id) VALUES (1, 1);
INSERT INTO TBL_COM_X_SPE (cxs_company_id, cxs_specialities_id) VALUES (1, 2);
INSERT INTO TBL_COM_X_SPE (cxs_company_id, cxs_specialities_id) VALUES (2, 3);

-- 10. TBL_CROPS_TYPE
INSERT INTO TBL_CROPS_TYPE (crt_id, crt_type) VALUES (1, 'Café');
INSERT INTO TBL_CROPS_TYPE (crt_id, crt_type) VALUES (2, 'Banano');
INSERT INTO TBL_CROPS_TYPE (crt_id, crt_type) VALUES (3, 'Piacaya');
INSERT INTO TBL_CROPS_TYPE (crt_id, crt_type) VALUES (4, 'Palmito');

-- 11. TBL_CROPS
INSERT INTO TBL_CROPS (cro_id, cro_age, cro_area) VALUES (1, TO_DATE('2024-01-15', 'YYYY-MM-DD'), 5.5);
INSERT INTO TBL_CROPS (cro_id, cro_age, cro_area) VALUES (2, TO_DATE('2023-06-20', 'YYYY-MM-DD'), 8.2);
INSERT INTO TBL_CROPS (cro_id, cro_age, cro_area) VALUES (3, TO_DATE('2024-03-10', 'YYYY-MM-DD'), 3.8);

-- 12. TBL_CRO_X_CRT
INSERT INTO TBL_CRO_X_CRT (cxc_crops_id, cxc_crops_type_id) VALUES (1, 1);
INSERT INTO TBL_CRO_X_CRT (cxc_crops_id, cxc_crops_type_id) VALUES (2, 2);
INSERT INTO TBL_CRO_X_CRT (cxc_crops_id, cxc_crops_type_id) VALUES (3, 3);

-- 13. TBL_FARMS
INSERT INTO TBL_FARMS (far_id, far_company_id, far_hectares, far_address_id, far_register_date) 
VALUES (1, 1, 25.5, 3, TO_DATE('2023-02-10', 'YYYY-MM-DD'));
INSERT INTO TBL_FARMS (far_id, far_company_id, far_hectares, far_address_id, far_register_date) 
VALUES (2, 2, 18.7, 4, TO_DATE('2024-01-20', 'YYYY-MM-DD'));

-- 14. TBL_FAR_X_CRO
INSERT INTO TBL_FAR_X_CRO (fxc_farms_id, fxc_crops_id) VALUES (1, 1);
INSERT INTO TBL_FAR_X_CRO (fxc_farms_id, fxc_crops_id) VALUES (1, 2);
INSERT INTO TBL_FAR_X_CRO (fxc_farms_id, fxc_crops_id) VALUES (2, 3);

-- 15. TBL_PRODUCERS
INSERT INTO TBL_PRODUCERS (pro_id, pro_person_id, pro_farm_id, pro_ocupation_id, pro_registration_date, pro_active) 
VALUES (1, 1, 1, 1, TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'S');
INSERT INTO TBL_PRODUCERS (pro_id, pro_person_id, pro_farm_id, pro_ocupation_id, pro_registration_date, pro_active) 
VALUES (2, 3, 2, 2, TO_DATE('2024-01-25', 'YYYY-MM-DD'), 'S');

-- 16. TBL_HISTORY_CROPS
INSERT INTO TBL_HISTORY_CROPS (hic_id, hic_farm_id, hic_harvest_date, hic_sowing_date) 
VALUES (1, 1, TO_DATE('2024-11-01', 'YYYY-MM-DD'), TO_DATE('2024-01-15', 'YYYY-MM-DD'));
INSERT INTO TBL_HISTORY_CROPS (hic_id, hic_farm_id, hic_harvest_date, hic_sowing_date) 
VALUES (2, 2, TO_DATE('2024-12-15', 'YYYY-MM-DD'), TO_DATE('2024-03-10', 'YYYY-MM-DD'));

-- 17. TBL_TECHNICAL_FILES
INSERT INTO TBL_TECHNICAL_FILES (tef_id, tef_history_crops_id, tef_creation_date, tef_objective, tef_conclusions, tef_recommendations) 
VALUES (1, 1, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Evaluación de suelo para café', 'Suelo ácido necesita enmienda', 'Aplicar cal agrícola 2 ton/ha');
INSERT INTO TBL_TECHNICAL_FILES (tef_id, tef_history_crops_id, tef_creation_date, tef_objective, tef_conclusions, tef_recommendations) 
VALUES (2, 2, TO_DATE('2024-11-08', 'YYYY-MM-DD'), 'Control de plagas en piacaya', 'Presencia de mildiu detectada', 'Aplicar fungicida sistémico');

-- 18. TBL_ANOTATIONS
INSERT INTO TBL_ANOTATIONS (ano_id, ano_technical_files_id, ano_title, ano_anotation, ano_date) 
VALUES (1, 1, 'Observación pH', 'pH medido en 5.3, muy ácido para café', TO_DATE('2024-11-05', 'YYYY-MM-DD'));
INSERT INTO TBL_ANOTATIONS (ano_id, ano_technical_files_id, ano_title, ano_anotation, ano_date) 
VALUES (2, 2, 'Detección temprana', 'Manchas amarillas en hojas inferiores', TO_DATE('2024-11-08', 'YYYY-MM-DD'));

-- 19. TBL_ENVIRONMENTALS_DATA
INSERT INTO TBL_ENVIRONMENTALS_DATA (end_id, end_technical_files_id, end_date) 
VALUES (1, 1, TO_DATE('2024-11-05', 'YYYY-MM-DD'));
INSERT INTO TBL_ENVIRONMENTALS_DATA (end_id, end_technical_files_id, end_date) 
VALUES (2, 2, TO_DATE('2024-11-08', 'YYYY-MM-DD'));

-- 20. TBL_SOILS
INSERT INTO TBL_SOILS (soi_id, soi_name) VALUES (1, 'Arcilloso');
INSERT INTO TBL_SOILS (soi_id, soi_name) VALUES (2, 'Franco');
INSERT INTO TBL_SOILS (soi_id, soi_name) VALUES (3, 'Arenoso');

-- 21. TBL_SOILS_TYPE
INSERT INTO TBL_SOILS_TYPE (sot_id, sot_environmental_data_id, sot_crops_id, sot_type_id) 
VALUES (1, 1, 1, 1);
INSERT INTO TBL_SOILS_TYPE (sot_id, sot_environmental_data_id, sot_crops_id, sot_type_id) 
VALUES (2, 2, 3, 2);

-- 22. TBL_WATER_SOURCES
INSERT INTO TBL_WATER_SOURCES (was_id, was_type, was_description, was_quality, was_quantity) 
VALUES (1, 'RÍO', 'Río Segundo de Alajuela', 'BUENA', 'ALTA');
INSERT INTO TBL_WATER_SOURCES (was_id, was_type, was_description, was_quality, was_quantity) 
VALUES (2, 'POZO', 'Pozo profundo 100m', 'REGULAR', 'MEDIA');

-- 23. TBL_END_X_WAS
INSERT INTO TBL_END_X_WAS (exw_environmental_data_id, exw_water_sources_id) VALUES (1, 1);
INSERT INTO TBL_END_X_WAS (exw_environmental_data_id, exw_water_sources_id) VALUES (2, 2);

-- 24. TBL_CLIMATIC_CONDITIONS
INSERT INTO TBL_CLIMATIC_CONDITIONS (clc_id, clc_environmental_data_id) VALUES (1, 1);
INSERT INTO TBL_CLIMATIC_CONDITIONS (clc_id, clc_environmental_data_id) VALUES (2, 2);

-- 25. TBL_LABORATORY_ANALYSIS
INSERT INTO TBL_LABORATORY_ANALYSIS (laa_id, laa_technical_files_id, laa_analysis_date, laa_results, laa_observations) 
VALUES (1, 1, TO_DATE('2024-11-06', 'YYYY-MM-DD'), 'pH=5.3, Materia orgánica=2.1%', 'Suelo requiere encalado urgente');
INSERT INTO TBL_LABORATORY_ANALYSIS (laa_id, laa_technical_files_id, laa_analysis_date, laa_results, laa_observations) 
VALUES (2, 2, TO_DATE('2024-11-09', 'YYYY-MM-DD'), 'Mildiu detectado en 40% plantas', 'Aplicar control químico preventivo');

-- 26. TBL_CERTFICATIONS
INSERT INTO TBL_CERTFICATIONS (cer_id, cer_name) VALUES (1, 'Certificación Orgánica');
INSERT INTO TBL_CERTFICATIONS (cer_id, cer_name) VALUES (2, 'Rainforest Alliance');
INSERT INTO TBL_CERTFICATIONS (cer_id, cer_name) VALUES (3, 'GlobalG.A.P.');

-- 27. TBL_TEF_X_CER
INSERT INTO TBL_TEF_X_CER (txc_technical_files_id, txc_certifications_id) VALUES (1, 1);
INSERT INTO TBL_TEF_X_CER (txc_technical_files_id, txc_certifications_id) VALUES (2, 2);

-- 28. TBL_TREATMENTS_TYPE
INSERT INTO TBL_TREATMENTS_TYPE (trt_id, trt_name) VALUES (1, 'Fertilización');
INSERT INTO TBL_TREATMENTS_TYPE (trt_id, trt_name) VALUES (2, 'Control Plagas');
INSERT INTO TBL_TREATMENTS_TYPE (trt_id, trt_name) VALUES (3, 'Enmienda Suelo');

-- 29. TBL_TREATMENTS
INSERT INTO TBL_TREATMENTS (tre_id, tre_treatment_type_id, tre_name) VALUES (1, 3, 'Encalado con cal agrícola');
INSERT INTO TBL_TREATMENTS (tre_id, tre_treatment_type_id, tre_name) VALUES (2, 2, 'Aplicación fungicida sistémico');

-- 30. TBL_TEF_X_TRE
INSERT INTO TBL_TEF_X_TRE (txt_technical_file_id, txt_treatments_id) VALUES (1, 1);
INSERT INTO TBL_TEF_X_TRE (txt_technical_file_id, txt_treatments_id) VALUES (2, 2);

-- 31. TBL_DISEASES
INSERT INTO TBL_DISEASES (dis_id, dis_name, dis_description, dis_severity) 
VALUES (1, 'Mildiu', 'Hongo que afecta hojas y frutos', 'MEDIA');
INSERT INTO TBL_DISEASES (dis_id, dis_name, dis_description, dis_severity) 
VALUES (2, 'Royas', 'Manchas anaranjadas en hojas', 'ALTA');

-- 32. TBL_FAR_X_DIS
INSERT INTO TBL_FAR_X_DIS (fxd_farms_id, fxd_diseases_id) VALUES (1, 1);
INSERT INTO TBL_FAR_X_DIS (fxd_farms_id, fxd_diseases_id) VALUES (2, 2);

-- 33. TBL_PESTS
INSERT INTO TBL_PESTS (pes_id, pes_name, pes_description, pes_severity) 
VALUES (1, 'Mosca blanca', 'Insecto chupador de savia', 'BAJA');
INSERT INTO TBL_PESTS (pes_id, pes_name, pes_description, pes_severity) 
VALUES (2, 'Broca del café', 'Perfora granos de café', 'CRÍTICA');

-- 34. TBL_FARM_X_PESTS
INSERT INTO TBL_FARM_X_PESTS (fxp_farms_id, fxp_pests_id) VALUES (1, 1);
INSERT INTO TBL_FARM_X_PESTS (fxp_farms_id, fxp_pests_id) VALUES (2, 2);

-- 35. TBL_SCHEDULE_AGRONOMISTS
INSERT INTO TBL_SCHEDULE_AGRONOMISTS (sca_id, sca_agronomist_id, sca_date, sca_start_time, sca_end_time, sca_visit_time) 
VALUES (1, 1, TO_DATE('2025-11-12', 'YYYY-MM-DD'), 8, 12, 30);
INSERT INTO TBL_SCHEDULE_AGRONOMISTS (sca_id, sca_agronomist_id, sca_date, sca_start_time, sca_end_time, sca_visit_time) 
VALUES (2, 2, TO_DATE('2025-11-13', 'YYYY-MM-DD'), 9, 13, 60);

-- 36. TBL_SCHEDULE_SPECIALITIES
INSERT INTO TBL_SCHEDULE_SPECIALITIES (scs_id, scs_specialite_id, scs_date, scs_start_time, scs_end_time, scs_visit_time) 
VALUES (1, 1, TO_DATE('2025-11-12', 'YYYY-MM-DD'), 8, 16, 30);
INSERT INTO TBL_SCHEDULE_SPECIALITIES (scs_id, scs_specialite_id, scs_date, scs_start_time, scs_end_time, scs_visit_time) 
VALUES (2, 2, TO_DATE('2025-11-13', 'YYYY-MM-DD'), 9, 17, 60);

-- 37. TBL_AVAILABILITIES
INSERT INTO TBL_AVAILABILITIES (ava_id, ava_schedule_agronomist_id, ava_schedule_specialite_id, ava_available) 
VALUES (1, 1, 1, 'DISPONIBLE');
INSERT INTO TBL_AVAILABILITIES (ava_id, ava_schedule_agronomist_id, ava_schedule_specialite_id, ava_available) 
VALUES (2, 2, 2, 'OCUPADO');

-- 38. TBL_VISITS
INSERT INTO TBL_VISITS (vis_id, vis_producer_id, vis_slots, vis_attendance, vis_available_id) 
VALUES (1, 1, 2, 'S', 1);
INSERT INTO TBL_VISITS (vis_id, vis_producer_id, vis_slots, vis_attendance, vis_available_id) 
VALUES (2, 2, 1, 'N', 2);

-- 39. TBL_CANCELLED_HISTORIES
INSERT INTO TBL_CANCELLED_HISTORIES (cah_id, cah_availaty_id, cah_visit_id) 
VALUES (1, 2, 2);

-- 40. TBL_FIELD_INSPECTIONS
INSERT INTO TBL_FIELD_INSPECTIONS (fii_id, fii_soil_ph, fii_humidity, fii_ambient_temperature, fii_nutrient_level, fii_crops_id, fii_agronomists_id) 
VALUES (1, 6.2, 75, 28.5, 'Óptimo', 1, 1);
INSERT INTO TBL_FIELD_INSPECTIONS (fii_id, fii_soil_ph, fii_humidity, fii_ambient_temperature, fii_nutrient_level, fii_crops_id, fii_agronomists_id) 
VALUES (2, 5.3, 80, 26.8, 'Bajo nitrógeno', 3, 2);

-- 41. TBL_ACCOUNT
INSERT INTO TBL_ACCOUNT (acc_id, acc_amount, acc_state, acc_person_id, acc_date) 
VALUES (1, 150000.00, 'PAGADO', 1, TO_DATE('2024-11-10', 'YYYY-MM-DD'));
INSERT INTO TBL_ACCOUNT (acc_id, acc_amount, acc_state, acc_person_id, acc_date) 
VALUES (2, 250000.00, 'CANCELADO', 3, TO_DATE('2024-11-09', 'YYYY-MM-DD'));

-- 42. TBL_COMISSIONS
INSERT INTO TBL_COMISSIONS (com_id, com_amount, com_agronomist_id, com_date) 
VALUES (1, 75000.00, 1, TO_DATE('2024-11-10', 'YYYY-MM-DD'));
INSERT INTO TBL_COMISSIONS (com_id, com_amount, com_agronomist_id, com_date) 
VALUES (2, 50000.00, 2, TO_DATE('2024-11-08', 'YYYY-MM-DD'));

-- 43. TBL_CONTACTS
INSERT INTO TBL_CONTACTS (con_id, con_type, con_contact) VALUES (1, 'CELULAR', '+506 8888-8888');
INSERT INTO TBL_CONTACTS (con_id, con_type, con_contact) VALUES (2, 'EMAIL', 'juan.rodriguez@agrosolutions.com');
INSERT INTO TBL_CONTACTS (con_id, con_type, con_contact) VALUES (3, 'TELÉFONO', '+506 2440-1234');
INSERT INTO TBL_CONTACTS (con_id, con_type, con_contact) VALUES (4, 'CELULAR', '+506 8999-9999');

-- 44. TBL_CON_X_COM
INSERT INTO TBL_CON_X_COM (cxc_company_id, cxc_contact_id) VALUES (1, 1);
INSERT INTO TBL_CON_X_COM (cxc_company_id, cxc_contact_id) VALUES (1, 2);
INSERT INTO TBL_CON_X_COM (cxc_company_id, cxc_contact_id) VALUES (2, 3);

-- 45. TBL_PER_X_CON
INSERT INTO TBL_PER_X_CON (pxc_person_id, pxc_contact_id) VALUES (1, 1);
INSERT INTO TBL_PER_X_CON (pxc_person_id, pxc_contact_id) VALUES (2, 2);
INSERT INTO TBL_PER_X_CON (pxc_person_id, pxc_contact_id) VALUES (3, 4);

commit;

select * from TBL_PERSON;
select * from TBL_COMPANIES;
select * from TBL_AGRONOMISTS;
select * from TBL_FARMS;
select * from TBL_PRODUCERS;
select * from TBL_TECHNICAL_FILES;
select * from TBL_SCHEDULE_AGRONOMISTS;
select * from TBL_AVAILABILITIES;
select * from TBL_VISITS;
select * from TBL_ACCOUNT;
select * from TBL_COMISSIONS;