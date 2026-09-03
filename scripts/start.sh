#!/usr/bin/env bash
# ============================================================
# start.sh
#
# Levanta la aplicacion completa (app + base de datos).
#
# Modo Docker (si docker esta disponible y responde):
#   docker compose up -d --build
#
# Modo local:
#   - Arranca PostgreSQL si no esta corriendo.
#   - Arranca el servidor web (Apache) con soporte CGI.
#
# Uso:
#   scripts/start.sh            # modo automatico (docker|local)
#   scripts/start.sh docker
#   scripts/start.sh local
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

if [[ ! -f .env ]]; then
    echo "Error: no existe .env. Copialo desde .env.example" >&2
    exit 1
fi

set -a
source .env
set +a

MODE="${1:-auto}"

if [[ "${MODE}" == "auto" ]]; then
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        MODE="docker"
    else
        MODE="local"
    fi
fi

if [[ "${MODE}" == "docker" ]]; then
    echo "== Arrancando con Docker =="
    docker compose up -d --build
    echo "Aplicacion levantada."
    echo "  Publica:  http://localhost:${APP_PORT}/"
    echo "  Admin:    http://localhost:${APP_PORT}/admin"
    echo "Detenerla con: scripts/stop.sh"
else
    echo "== Arrancando en modo local =="

    # 1. PostgreSQL
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        echo "PostgreSQL ya esta corriendo."
    else
        echo "Iniciando PostgreSQL..."
        sudo systemctl start postgresql 2>/dev/null \
            || sudo service postgresql start
    fi

    # 2. Preparar la base (idempotente)
    if ! PGPASSWORD="${DB_PASSWORD}" psql -U "${DB_USER}" -h "${DB_HOST}" \
        -p "${DB_PORT}" -d "${DB_NAME}" -c "SELECT 1" >/dev/null 2>&1; then
        echo "La base de datos no esta lista. Ejecutando setup-db.sh..."
        "${SCRIPT_DIR}/setup-db.sh"
    fi

    # 3. Apache
    if systemctl is-active --quiet apache2 2>/dev/null; then
        echo "Apache ya esta corriendo."
    else
        echo "Iniciando Apache..."
        sudo systemctl start apache2 2>/dev/null \
            || sudo service apache2 start
    fi

    echo "Aplicacion levantada en modo local."
    echo "  Publica:  http://localhost/student-crud/"
    echo "  Admin:    http://localhost/student-crud/admin"
    echo "Detenerla con: scripts/stop.sh"
fi
