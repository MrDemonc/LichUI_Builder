#!/bin/bash
# Forzar carga de entorno
export dir_work="$(pwd)"
source ./build.sh a54x > /dev/null

echo "Config loaded:"
echo "TARGET_FIRMWARE: $TARGET_FIRMWARE"
echo "SOURCE_FIRMWARE: $SOURCE_FIRMWARE"

source scripts/utils/utils.sh

# Ejecutar manualmente la transformación para estar seguros
setup_firmware_vars
echo "Names generated:"
echo "TARGET_FIRMWARE_NAME: $TARGET_FIRMWARE_NAME"
echo "SOURCE_FIRMWARE_NAME: $SOURCE_FIRMWARE_NAME"

echo "Creando archivo de prueba..."
echo "echo 'Hello World'" > test_tool.sh
chmod +x test_tool.sh

echo -e "\nEjecutando: add system test_tool.sh bin/test_tool"
add system test_tool.sh bin/test_tool

echo -e "\nEjecutando: add vendor test_tool.sh etc/test_config"
add vendor test_tool.sh etc/test_config

echo -e "\n--- VERIFICACIÓN ---"
find out/firmware -name "test_tool" || echo "test_tool not found in out/firmware"
find out/firmware -name "test_config" || echo "test_config not found in out/firmware"

# Limpiar
rm test_tool.sh
