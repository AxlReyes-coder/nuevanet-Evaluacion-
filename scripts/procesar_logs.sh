#!/usr/bin/env bash
# =============================================================
# procesar_logs.sh - NuevaNet
# Genera un reporte de errores de los logs y comprime los antiguos.
# Uso: procesar_logs.sh [directorio_de_logs]
# Códigos de salida: 0 OK | 1 directorio inexistente
#                    2 sin permisos | 3 no se pudo crear reporte
# =============================================================
set -euo pipefail

LOG_DIR="${1:-$HOME/nuevanet/logs}"
REPORTE_DIR="$HOME/nuevanet/reportes"
BITACORA="$HOME/nuevanet/automatizacion.log"
DIAS_ANTIGUEDAD=7

# Registra en pantalla y en la bitácora con fecha y nivel
log() { echo "$(date '+%F %T') [$1] $2" | tee -a "$BITACORA"; }

# --- Validaciones ---
if [[ ! -d "$LOG_DIR" ]]; then
    log ERROR "El directorio no existe: $LOG_DIR"
    exit 1
fi
if [[ ! -r "$LOG_DIR" || ! -x "$LOG_DIR" ]]; then
    log ERROR "Permiso denegado en: $LOG_DIR"
    exit 2
fi
if ! mkdir -p "$REPORTE_DIR"; then
    log ERROR "No se pudo crear: $REPORTE_DIR"
    exit 3
fi

# --- Procesamiento: top 20 de líneas con error ---
REPORTE="$REPORTE_DIR/errores_$(date +%F).txt"
log INFO "Procesando logs en $LOG_DIR"
# || true: si no hay coincidencias, grep devuelve 1 y no debe abortar el script
grep -rihE "error|fail|denied" "$LOG_DIR" --include="*.log" \
    | sort | uniq -c | sort -rn | head -20 > "$REPORTE" || true
log INFO "Reporte generado: $REPORTE ($(wc -l < "$REPORTE") líneas)"

# --- Proceso nocturno: comprimir logs antiguos ---
ANTIGUOS=$(find "$LOG_DIR" -name "*.log" -mtime +"$DIAS_ANTIGUEDAD" | wc -l)
find "$LOG_DIR" -name "*.log" -mtime +"$DIAS_ANTIGUEDAD" -exec gzip -f {} \;
log INFO "Logs comprimidos (más de $DIAS_ANTIGUEDAD días): $ANTIGUOS"
log INFO "Proceso finalizado correctamente"
