CREATE OR REPLACE PROCEDURE pcr_generate_semester_pests_diseases_report AS
    v_email_recipient VARCHAR2(100);
    v_subject VARCHAR2(200);
    v_message CLOB;
    v_semester VARCHAR2(50);
    v_total_cases NUMBER := 0;
    v_database_name VARCHAR2(100);
    v_generation_date VARCHAR2(50);
    
    -- Cursor para plagas más comunes
    CURSOR c_top_pests IS
        SELECT 
            p.pes_name as pest_name,
            p.pes_severity,
            COUNT(fxp.fxp_farms_id) as total_cases,
            COUNT(DISTINCT f.far_id) as affected_farms,
            LISTAGG(DISTINCT add_province, ', ') WITHIN GROUP (ORDER BY add_province) as provinces,
            LISTAGG(DISTINCT ct.crt_type, ', ') WITHIN GROUP (ORDER BY ct.crt_type) as crop_types
        FROM TBL_FARM_X_PESTS fxp
        JOIN TBL_PESTS p ON fxp.fxp_pests_id = p.pes_id
        JOIN TBL_FARMS f ON fxp.fxp_farms_id = f.far_id
        JOIN TBL_ADDRESS a ON f.far_address_id = a.add_id
        JOIN TBL_FAR_X_CRO fxc ON f.far_id = fxc.fxc_farms_id
        JOIN TBL_CROPS cr ON fxc.fxc_crops_id = cr.cro_id
        JOIN TBL_CRO_X_CRT cxc ON cr.cro_id = cxc.cxc_crops_id
        JOIN TBL_CROPS_TYPE ct ON cxc.cxc_crops_type_id = ct.crt_id
        WHERE EXISTS (
            SELECT 1 FROM TBL_TECHNICAL_FILES tf
            JOIN TBL_TEF_X_FAR txf ON tf.tef_id = txf.txf_technical_files_id
            WHERE txf.txf_farms_id = f.far_id
              AND tf.tef_creation_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
        )
        GROUP BY p.pes_name, p.pes_severity
        ORDER BY total_cases DESC
        FETCH FIRST 10 ROWS ONLY;
    
    -- Cursor para enfermedades más comunes
    CURSOR c_top_diseases IS
        SELECT 
            d.dis_name as disease_name,
            d.dis_severity,
            COUNT(fxd.fxd_farms_id) as total_cases,
            COUNT(DISTINCT f.far_id) as affected_farms,
            LISTAGG(DISTINCT add_province, ', ') WITHIN GROUP (ORDER BY add_province) as provinces,
            LISTAGG(DISTINCT ct.crt_type, ', ') WITHIN GROUP (ORDER BY ct.crt_type) as crop_types
        FROM TBL_FAR_X_DIS fxd
        JOIN TBL_DISEASES d ON fxd.fxd_diseases_id = d.dis_id
        JOIN TBL_FARMS f ON fxd.fxd_farms_id = f.far_id
        JOIN TBL_ADDRESS a ON f.far_address_id = a.add_id
        JOIN TBL_FAR_X_CRO fxc ON f.far_id = fxc.fxc_farms_id
        JOIN TBL_CROPS cr ON fxc.fxc_crops_id = cr.cro_id
        JOIN TBL_CRO_X_CRT cxc ON cr.cro_id = cxc.cxc_crops_id
        JOIN TBL_CROPS_TYPE ct ON cxc.cxc_crops_type_id = ct.crt_id
        WHERE EXISTS (
            SELECT 1 FROM TBL_TECHNICAL_FILES tf
            JOIN TBL_TEF_X_FAR txf ON tf.tef_id = txf.txf_technical_files_id
            WHERE txf.txf_farms_id = f.far_id
              AND tf.tef_creation_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
        )
        GROUP BY d.dis_name, d.dis_severity
        ORDER BY total_cases DESC
        FETCH FIRST 10 ROWS ONLY;
    
    -- Cursor para estadísticas por región
    CURSOR c_region_stats IS
        SELECT 
            a.add_province as region,
            COUNT(DISTINCT f.far_id) as total_farms,
            COUNT(DISTINCT fxp.fxp_pests_id) as pest_cases,
            COUNT(DISTINCT fxd.fxd_diseases_id) as disease_cases,
            (COUNT(DISTINCT fxp.fxp_pests_id) + COUNT(DISTINCT fxd.fxd_diseases_id)) as total_cases
        FROM TBL_FARMS f
        JOIN TBL_ADDRESS a ON f.far_address_id = a.add_id
        LEFT JOIN TBL_FARM_X_PESTS fxp ON f.far_id = fxp.fxp_farms_id
        LEFT JOIN TBL_FAR_X_DIS fxd ON f.far_id = fxd.fxd_farms_id
        WHERE EXISTS (
            SELECT 1 FROM TBL_TECHNICAL_FILES tf
            JOIN TBL_TEF_X_FAR txf ON tf.tef_id = txf.txf_technical_files_id
            WHERE txf.txf_farms_id = f.far_id
              AND tf.tef_creation_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
        )
        GROUP BY a.add_province
        ORDER BY total_cases DESC;
    
    -- Cursor para estadísticas por tipo de cultivo
    CURSOR c_crop_stats IS
        SELECT 
            ct.crt_type as crop_type,
            COUNT(DISTINCT f.far_id) as affected_farms,
            COUNT(DISTINCT fxp.fxp_pests_id) as pest_cases,
            COUNT(DISTINCT fxd.fxd_diseases_id) as disease_cases,
            (COUNT(DISTINCT fxp.fxp_pests_id) + COUNT(DISTINCT fxd.fxd_diseases_id)) as total_cases
        FROM TBL_CROPS_TYPE ct
        JOIN TBL_CRO_X_CRT cxc ON ct.crt_id = cxc.cxc_crops_type_id
        JOIN TBL_CROPS cr ON cxc.cxc_crops_id = cr.cro_id
        JOIN TBL_FAR_X_CRO fxc ON cr.cro_id = fxc.fxc_crops_id
        JOIN TBL_FARMS f ON fxc.fxc_farms_id = f.far_id
        LEFT JOIN TBL_FARM_X_PESTS fxp ON f.far_id = fxp.fxp_farms_id
        LEFT JOIN TBL_FAR_X_DIS fxd ON f.far_id = fxd.fxd_farms_id
        WHERE EXISTS (
            SELECT 1 FROM TBL_TECHNICAL_FILES tf
            JOIN TBL_TEF_X_FAR txf ON tf.tef_id = txf.txf_technical_files_id
            WHERE txf.txf_farms_id = f.far_id
              AND tf.tef_creation_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
        )
        GROUP BY ct.crt_type
        ORDER BY total_cases DESC;
    
    -- Cursor para estadísticas generales
    CURSOR c_general_stats IS
        SELECT 
            COUNT(DISTINCT f.far_id) as total_farms_affected,
            COUNT(DISTINCT fxp.fxp_pests_id) as total_pest_types,
            COUNT(DISTINCT fxd.fxd_diseases_id) as total_disease_types,
            COUNT(fxp.fxp_farms_id) as total_pest_cases,
            COUNT(fxd.fxd_farms_id) as total_disease_cases,
            (COUNT(fxp.fxp_farms_id) + COUNT(fxd.fxd_farms_id)) as grand_total_cases,
            COUNT(DISTINCT a.add_province) as regions_affected,
            COUNT(DISTINCT ct.crt_id) as crop_types_affected
        FROM TBL_FARMS f
        JOIN TBL_ADDRESS a ON f.far_address_id = a.add_id
        LEFT JOIN TBL_FARM_X_PESTS fxp ON f.far_id = fxp.fxp_farms_id
        LEFT JOIN TBL_FAR_X_DIS fxd ON f.far_id = fxd.fxd_farms_id
        LEFT JOIN TBL_FAR_X_CRO fxc ON f.far_id = fxc.fxc_farms_id
        LEFT JOIN TBL_CROPS cr ON fxc.fxc_crops_id = cr.cro_id
        LEFT JOIN TBL_CRO_X_CRT cxc ON cr.cro_id = cxc.cxc_crops_id
        LEFT JOIN TBL_CROPS_TYPE ct ON cxc.cxc_crops_type_id = ct.crt_id
        WHERE EXISTS (
            SELECT 1 FROM TBL_TECHNICAL_FILES tf
            JOIN TBL_TEF_X_FAR txf ON tf.tef_id = txf.txf_technical_files_id
            WHERE txf.txf_farms_id = f.far_id
              AND tf.tef_creation_date >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
        );

BEGIN
    DBMS_OUTPUT.PUT_LINE('Generando reporte semestral de plagas y enfermedades...');
    
    -- Obtener información antes de construir el mensaje
    SELECT name INTO v_database_name FROM v$database;
    v_generation_date := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI');
    
    -- Determinar el semestre
    IF EXTRACT(MONTH FROM SYSDATE) <= 6 THEN
        v_semester := 'Enero-Junio ' || EXTRACT(YEAR FROM SYSDATE);
    ELSE
        v_semester := 'Julio-Diciembre ' || EXTRACT(YEAR FROM SYSDATE);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Semestre del reporte: ' || v_semester);
    

    v_email_recipient := 'jorgerojas765lt@gmail.com';
    
    -- Construir el reporte
    v_subject := 'Reporte Semestral Plagas/Enfermedades - ' || v_semester;
    
    v_message := 
        'REPORTE SEMESTRAL DE PLAGAS Y ENFERMEDADES' || CHR(10) ||
        '==========================================' || CHR(10) || CHR(10) ||
        
        'INFORMACION GENERAL:' || CHR(10) ||
        '• Periodo: ' || v_semester || CHR(10) ||
        '• Fecha de generacion: ' || v_generation_date || CHR(10) ||
        '• Base de datos: ' || v_database_name || CHR(10) || CHR(10);
    
    -- Sección 1: Estadísticas generales
    FOR rec IN c_general_stats LOOP
        v_message := v_message || 
            'ESTADISTICAS GENERALES:' || CHR(10) ||
            '-----------------------' || CHR(10) ||
            '• Fincas afectadas: ' || rec.total_farms_affected || CHR(10) ||
            '• Tipos de plagas: ' || rec.total_pest_types || CHR(10) ||
            '• Tipos de enfermedades: ' || rec.total_disease_types || CHR(10) ||
            '• Casos de plagas: ' || rec.total_pest_cases || CHR(10) ||
            '• Casos de enfermedades: ' || rec.total_disease_cases || CHR(10) ||
            '• Total de casos: ' || rec.grand_total_cases || CHR(10) ||
            '• Regiones afectadas: ' || rec.regions_affected || CHR(10) ||
            '• Tipos de cultivo afectados: ' || rec.crop_types_affected || CHR(10) || CHR(10);
        
        v_total_cases := rec.grand_total_cases;
    END LOOP;
    
    -- Sección 2: Top plagas
    v_message := v_message || 
        'TOP 10 PLAGAS MAS COMUNES:' || CHR(10) ||
        '---------------------------' || CHR(10);
    
    FOR rec IN c_top_pests LOOP
        v_message := v_message ||
            rec.pest_name || CHR(10) ||
            '   Severidad: ' || rec.pes_severity || CHR(10) ||
            '   Casos totales: ' || rec.total_cases || CHR(10) ||
            '   Fincas afectadas: ' || rec.affected_farms || CHR(10) ||
            '   Regiones: ' || rec.provinces || CHR(10) ||
            '   Cultivos: ' || rec.crop_types || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 3: Top enfermedades
    v_message := v_message || 
        'TOP 10 ENFERMEDADES MAS COMUNES:' || CHR(10) ||
        '--------------------------------' || CHR(10);
    
    FOR rec IN c_top_diseases LOOP
        v_message := v_message ||
            rec.disease_name || CHR(10) ||
            '   Severidad: ' || rec.dis_severity || CHR(10) ||
            '   Casos totales: ' || rec.total_cases || CHR(10) ||
            '   Fincas afectadas: ' || rec.affected_farms || CHR(10) ||
            '   Regiones: ' || rec.provinces || CHR(10) ||
            '   Cultivos: ' || rec.crop_types || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 4: Análisis por región
    v_message := v_message || 
        'DISTRIBUCION POR REGION:' || CHR(10) ||
        '--------------------------' || CHR(10);
    
    FOR rec IN c_region_stats LOOP
        v_message := v_message ||
            rec.region || CHR(10) ||
            '   Fincas: ' || rec.total_farms || CHR(10) ||
            '   Casos plagas: ' || rec.pest_cases || CHR(10) ||
            '   Casos enfermedades: ' || rec.disease_cases || CHR(10) ||
            '   Total casos: ' || rec.total_cases || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 5: Análisis por tipo de cultivo
    v_message := v_message || 
        'DISTRIBUCION POR TIPO DE CULTIVO:' || CHR(10) ||
        '----------------------------------' || CHR(10);
    
    FOR rec IN c_crop_stats LOOP
        v_message := v_message ||
            rec.crop_type || CHR(10) ||
            '   Fincas afectadas: ' || rec.affected_farms || CHR(10) ||
            '   Casos plagas: ' || rec.pest_cases || CHR(10) ||
            '   Casos enfermedades: ' || rec.disease_cases || CHR(10) ||
            '   Total casos: ' || rec.total_cases || CHR(10) ||
            '---' || CHR(10);
    END LOOP;
    
    v_message := v_message || CHR(10);
    
    -- Sección 6: Recomendaciones
    v_message := v_message || 
        'RECOMENDACIONES TECNICAS:' || CHR(10) ||
        '--------------------------' || CHR(10);
    
    -- Recomendaciones basadas en los datos
    IF v_total_cases > 100 THEN
        v_message := v_message || '• Alta incidencia de problemas fitosanitarios en el semestre' || CHR(10);
        v_message := v_message || '• Considerar programas de prevencion masiva' || CHR(10);
    ELSIF v_total_cases > 50 THEN
        v_message := v_message || '• Incidencia moderada, mantener programas de monitoreo' || CHR(10);
    ELSE
        v_message := v_message || '• Baja incidencia, buen estado fitosanitario general' || CHR(10);
    END IF;
    
    v_message := v_message || 
        '• Implementar programas de manejo integrado para las plagas/enfermedades mas frecuentes' || CHR(10) ||
        '• Reforzar capacitacion en identificacion temprana de problemas' || CHR(10) ||
        '• Considerar variedades resistentes para los cultivos mas afectados' || CHR(10) || CHR(10) ||
        
        'METODOLOGIA:' || CHR(10) ||
        '• Periodo: Ultimos 6 meses' || CHR(10) ||
        '• Solo se consideran casos con expedientes tecnicos activos' || CHR(10) ||
        '• Incluye todas las regiones y tipos de cultivo' || CHR(10) ||
        '• Ordenado por numero total de casos' || CHR(10) || CHR(10) ||
        
        '-- Reporte automatico generado por el sistema --';
    
    -- Enviar reporte al gerente
    pcr_send_email(
        p_recipient => v_email_recipient,
        p_subject => v_subject,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Reporte semestral de plagas/enfermedades enviado a: ' || v_email_recipient);
    DBMS_OUTPUT.PUT_LINE('Total casos reportados: ' || v_total_cases);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error generando reporte semestral: ' || SQLERRM);
        
        -- Notificar error al gerente
        BEGIN
            v_subject := 'Error en Reporte Plagas/Enfermedades - ' || v_semester;
            v_message := 
                'Error generando el reporte semestral de plagas y enfermedades:' || CHR(10) || CHR(10) ||
                'Error: ' || SQLERRM || CHR(10) ||
                'Fecha: ' || v_generation_date || CHR(10) ||
                'Por favor, contacte al administrador del sistema.';
                
            pcr_send_email(
                p_recipient => v_email_recipient,
                p_subject => v_subject,
                p_message => v_message
            );
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
END pcr_generate_semester_pests_diseases_report;
/