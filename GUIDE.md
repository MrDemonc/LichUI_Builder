# Guía de Funciones: add y delete

Esta guía explica cómo utilizar las funciones principales de manipulación de archivos en el proyecto LichUI_Builder.

## Configuración Inicial
Para usar estas funciones en cualquier script, primero debes importar el archivo de utilidades:

```bash
#!/bin/bash
source "scripts/utils/utils.sh"
```

---

## 1. Función `add`
Sirve para añadir un archivo a una partición específica. Se encarga automáticamente de copiar el archivo y actualizar los metadatos de permisos (`fs_config`) y contextos de seguridad (`file_context`).

**Sintaxis:**
```bash
add <partición> <archivo_origen> <ruta_destino>
```

**Parámetros:**
- `<partición>`: La partición destino (ej: `system`, `vendor`, `product`).
- `<archivo_origen>`: Ruta local del archivo que quieres subir.
- `<ruta_destino>`: Ruta relativa dentro de la partición (ej: `/etc/hosts`).

**Lógica de carpetas:**
- Si usas `system` o `product`, el archivo se añadirá al **Source Firmware** (`SOURCE_DIR`).
- Para cualquier otra partición, se usará el **Target Firmware** (`TARGET_DIR`).

**Ejemplo:**
```bash
add system "mis_parches/hosts" "/etc/hosts"
```

---

## 2. Función `delete`
Sirve para eliminar un archivo o directorio de una partición y limpiar sus rastros en los metadatos.

**Sintaxis:**
```bash
delete <partición> <ruta_en_particion>
```

**Parámetros:**
- `<partición>`: La partición donde está el archivo.
- `<ruta_en_particion>`: Ruta del archivo a eliminar (ej: `/app/Bloatware`).

**Lógica:**
- Elimina el archivo físicamente del disco.
- Borra la línea correspondiente en `fs_config`.
- Borra la entrada correspondiente en `file_context`.

**Ejemplo:**
```bash
delete system "/app/SamsungBloat"
```

---

## 3. Función `setprop`
Modifica archivos de propiedades (como `build.prop`) de forma masiva usando un archivo externo.

**Sintaxis:**
```bash
setprop <partición> [subdir] <archivo_prop>
```

**Parámetros:**
- `<partición>`: La partición (sistema, vendor, etc.).
- `[subdir]` (Opcional): Si el `build.prop` está en una subcarpeta específica (ej: `etc`).
- `<archivo_prop>`: Tu archivo con los cambios.

**Secciones del archivo `.prop`:**
El archivo que pases como parámetro debe estar dividido por estos encabezados:

1. `# Change`: Cambia el valor de una propiedad o la crea si no existe.
   - Ejemplo: `ro.config.low_ram=false`
2. `# Clear`: Vacía el valor de una propiedad, dejándola como `clave=`.
   - Ejemplo: `ro.build.user=`
3. `# Delete`: Borra la línea completa de la propiedad del archivo.
   - Ejemplo: `ro.config.ringtone` (sin el signo igual)

**Ejemplo de uso:**
```bash
setprop system "patches/tweaks.prop"
```

- **Permisos automáticos**: Si el archivo que añades con `add` tiene permisos de ejecución en tu PC, se guardará con permisos `755`. Si no, se guardará como `644`.
- **Rutas**: No importa si pones una `/` al principio de la ruta de destino, la función la limpiará automáticamente para evitar errores.
