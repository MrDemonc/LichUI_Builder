#!/bin/bash
export dir_work="$(pwd)"
source ./build.sh a54x > /dev/null
source scripts/utils/utils.sh

echo "Verificando existencia previa..."
ls -l out/firmware/SM-S711B_EUX/system/system/bin/test_tool
grep "system/bin/test_tool" out/firmware/SM-S711B_EUX/fs_config-system

echo -e "\nEjecutando: delete system bin/test_tool"
delete system bin/test_tool

echo -e "\n--- VERIFICACIÓN POST-ELIMINACIÓN ---"
if [ ! -f "out/firmware/SM-S711B_EUX/system/system/bin/test_tool" ]; then
    echo "[V] Archivo eliminado físicamente."
else
    echo "[X] El archivo aún existe."
fi

echo "Buscando en fs_config-system:"
grep "system/bin/test_tool" out/firmware/SM-S711B_EUX/fs_config-system || echo "[V] Entrada eliminada de fs_config."

echo "Buscando en file_context-system:"
grep "system/bin/test_tool" out/firmware/SM-S711B_EUX/file_context-system || echo "[V] Entrada eliminada de file_context."
