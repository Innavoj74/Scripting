-- backup_script.sql
-- Script para generar múltiples backups

SET SERVEROUTPUT ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 100

DECLARE
    v_fecha VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS');
    v_archivo_dmp VARCHAR2(100);
    v_archivo_log VARCHAR2(100);
    v_comando VARCHAR2(1000);
    v_directory VARCHAR2(50) := 'DATA_PUMP_DIR';
    v_esquema VARCHAR2(50) := 'MI_ESQUEMA';
    
    -- Función para verificar espacio
    FUNCTION verificar_espacio RETURN BOOLEAN IS
        v_espacio_libre NUMBER;
    BEGIN
        SELECT ROUND(SUM(bytes)/1024/1024/1024, 2)
        INTO v_espacio_libre
        FROM dba_free_space
        WHERE tablespace_name = 'USERS';
        
        DBMS_OUTPUT.PUT_LINE('Espacio libre en tablespace USERS: ' || v_espacio_libre || ' GB');
        
        RETURN v_espacio_libre > 1; -- Al menos 1GB libre
    END;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO PROCESO DE BACKUP ===');
    DBMS_OUTPUT.PUT_LINE('Fecha: ' || v_fecha);
    
    -- Verificar espacio disponible
    IF NOT verificar_espacio THEN
        RAISE_APPLICATION_ERROR(-20001, 'Espacio insuficiente para realizar backup');
    END IF;
    
    -- Configurar nombres de archivos
    v_archivo_dmp := v_esquema || '_' || v_fecha || '.dmp';
    v_archivo_log := v_esquema || '_' || v_fecha || '.log';
    
    -- Generar comando de exportación
    v_comando := 'expdp system/manager@dbora ' ||
                 'schemas=' || v_esquema || ' ' ||
                 'directory=' || v_directory || ' ' ||
                 'dumpfile=' || v_archivo_dmp || ' ' ||
                 'logfile=' || v_archivo_log || ' ' ||
                 'compression=ALL ' ||
                 'parallel=2 ' ||
                 'version=12';
    
    DBMS_OUTPUT.PUT_LINE('Comando a ejecutar:');
    DBMS_OUTPUT.PUT_LINE(v_comando);
    
    -- Aquí se ejecutaría el comando externo
    -- En producción usaría DBMS_SCHEDULER para programarlo
    
    -- Exportar metadata importante
    DBMS_METADATA.SET_TRANSFORM_PARAM(
        DBMS_METADATA.SESSION_TRANSFORM,
        'SQLTERMINATOR',
        TRUE
    );
    
    DBMS_OUTPUT.PUT_LINE('=== BACKUP PROGRAMADO ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
/