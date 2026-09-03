#!/usr/bin/env bash
# ============================================================
# stop.sh
#
# Detiene la aplicacion.
#
# Modo Docker:
#   docker compose down   (elimina los contenedores; la data de la DB
#                          persiste en el volumen si NO se usa -v)
#
# Modo local:
#   Detiene Apache (opcionalmente PostgreSQL con el flag -pg).
#
# Uso:
#   scripts/stop.sh            # modo automatico (docker|local)
#   scripts/stop.sh -pg        # ademas detiene postgres en modo local
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

STOP_PG=0
if [[ "${1:-}" == "-pg" ]]; then
    STOP_PG=1
fi

MODE="${1:-auto}"
if [[ "${MODE}" == "auto" ]]; then
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        MODE="docker"
    else
        MODE="local"
    fi
fi

if [[ "${MODE}" == "docker" ]]; then
    echo "== Deteniendo con Docker =="
    docker compose down
    echo "Aplicacion detenida. Para eliminar tambien la data de la DB:"
    echo "  docker compose down -v"
else
    echo "== Deteniendo en modo local =="

    if systemctl is-active --quiet apache2 2>/dev/null; then
        echo "Deteniendo Apache..."
        sudo systemctl stop apache2 2>/dev/null \
            || sudo service apache2 stop
    else
        echo "Apache no esta corriendo."
    fi

    if [[ "${STOP_PG}" -eq 1 ]]; then
        if systemctl is-active --quiet postgresql 2>/dev/null; then
            echo "Deteniendo PostgreSQL..."
            sudo systemctl stop postgresql 2>/dev/null \
                || sudo service postgresql stop
        else
            echo "PostgreSQL no estaba corriendo."
        fi
    else
        echo "PostgreSQL se deja corriendo (usalo con -pg para detenerlo)."
    fi
fi
