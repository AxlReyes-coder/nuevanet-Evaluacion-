#!/usr/bin/env bash
# =============================================================
# respaldo.sh - NuevaNet
# Respaldo completo o incremental de un directorio con tar.
# Uso: respaldo.sh [completo|incremental]
# Variables opcionales: ORIGEN, DESTINO
# Códigos de salida: 0 OK | 1 origen inexistente | 2 sin permisos
#                    3 tipo inválido | 4 fallo de tar
# =============================================================
set -euo pipefail

ORIGEN="${ORIGEN:-$HOME/nuevanet/datos}"
DESTINO="${DESTINO:-$HOME/nuevanet/respaldos}"
TIPO="${1:-incremental}"
SNAR="$DESTINO/nuevanet.snar"      # registro de lo ya respaldado
FECHA=$(date +%F_%H%M%S)
LOG="$DESTINO/respaldo.log"
RETENCION_DIAS=14

mkdir -p "$DESTINO" || { echo "No se pudo crear $DESTINO"; exit 1; }
log() { echo "$(date '+%F %T') [$1] $2" | tee -a "$LOG"; }

# --- Validaciones ---
if [[ ! -d "$ORIGEN" ]]; then
    log ERROR "El origen no existe: $ORIGEN"; exit 1
fi
if [[ ! -r "$ORIGEN" || ! -x "$ORIGEN" ]]; then
    log ERROR "Permiso denegado en: $ORIGEN"; exit 2
fi

case "$TIPO" in
    completo)    rm -f "$SNAR" ;;   # sin snapshot, tar copia todo
    incremental) ;;                 # con snapshot, tar copia solo lo nuevo
    *) log ERROR "Tipo inválido '$TIPO' (use: completo | incremental)"; exit 3 ;;
esac

ARCHIVO="$DESTINO/${TIPO}_${FECHA}.tar.gz"
log INFO "Iniciando respaldo $TIPO de $ORIGEN"

if ! tar --listed-incremental="$SNAR" -czf "$ARCHIVO" \
        -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")"; then
    log ERROR "Falló tar al crear $ARCHIVO"
    rm -f "$ARCHIVO"
    exit 4
fi
log INFO "Respaldo creado: $ARCHIVO ($(du -h "$ARCHIVO" | cut -f1))"

# --- Retención: elimina respaldos antiguos ---
BORRADOS=$(find "$DESTINO" -name "*.tar.gz" -mtime +"$RETENCION_DIAS" -print -delete | wc -l)
log INFO "Respaldos antiguos eliminados: $BORRADOS"
