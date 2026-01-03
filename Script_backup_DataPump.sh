#!/bin/bash

# Script para exportar datos de Oracle usando Data Pump
# Configuración de variables
export FECHA=$(date +%Y%m%d_%H%M%S)
export ORACLE_SID=ORCL
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Credenciales (alternativa: usar wallet)
USUARIO="system"
PASSWORD="manaer"
ESQUEMA="persons"

# Directorio de exportación
DIR_EXPORT="/backup/oracle/export"
DIR_DUMP="DATA_PUMP_DIR"  # Directorio de Oracle
ARCHIVO_EXPORT="${ESQUEMA}_${FECHA}.dmp"
ARCHIVO_LOG="${ESQUEMA}_${FECHA}.log"

# Crear directorio si no existe
mkdir -p $DIR_EXPORT

echo "=========================================="
echo "Iniciando exportación de datos"
echo "Fecha: $FECHA"
echo "Esquema: $ESQUEMA"
echo "=========================================="

# Exportar usando expdp
expdp $USUARIO/$PASSWORD@$ORACLE_SID \
  schemas=$ESQUEMA \
  directory=$DIR_DUMP \
  dumpfile=$ARCHIVO_EXPORT \
  logfile=$ARCHIVO_LOG \
  compression=ALL \
  parallel=2

# Verificar resultado
if [ $? -eq 0 ]; then
    echo "Exportación completada exitosamente"
    echo "Archivo dump: $ARCHIVO_EXPORT"
    echo "Log: $ARCHIVO_LOG"
    
    # Opcional: Copiar a directorio local
    # cp $ORACLE_HOME/rdbms/log/$ARCHIVO_LOG $DIR_EXPORT/
    
    # Opcional: Comprimir
    # gzip $DIR_EXPORT/$ARCHIVO_EXPORT
    
else
    echo "Error en la exportación"
    exit 1
fi

# Listar archivos creados
echo "Archivos en directorio de exportación:"
ls -lh $DIR_EXPORT/*${FECHA}* 2>/dev/null || echo "No se encontraron archivos de esta exportación"

echo "=========================================="
echo "Proceso finalizado"