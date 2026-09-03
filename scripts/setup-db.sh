#!/usr/bin/env bash
# ============================================================
# setup-db.sh
#
# Prepara la base de datos PostgreSQL para la aplicacion:
#   - Crea el rol (usuario), la base de datos y los permisos.
#   - Aplica sql/schema.sql (esquema + datos semilla).
#
# Uso:
#   scripts/setup-db.sh            # modo automatico (docker|local)
#   scripts/setup-db.sh docker     # fuerza modo docker
#   scripts/setup-db.sh local      # fuerza modo local
#
# Las credenciales se leen de .env (DB_NAME, DB_USER, DB_PASSWORD).
#
# Para el superusuario postgres en modo local: por defecto se usa
# "sudo -u postgres psql". Si tu instalacion no permite sudo, defini
# la variable de entorno PGPASSWORD_SUPERUSER con la password de postgres:
#   PGPASSWORD_SUPERUSER="xxx" scripts/setup-db.sh local
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

if [[ ! -f .env ]]; then
    echo "Error: no existe .env. Copialo desde .env.example" >&2
    exit 1
fi

# shellcheck disable=SC1091
set -a
source .env
set +a

SCHEMA="${ROOT_DIR}/sql/schema.sql"

MODE="${1:-auto}"

if [[ "${MODE}" == "auto" ]]; then
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        MODE="docker"
    else
        MODE="local"
    fi
fi

if [[ "${MODE}" == "docker" ]]; then
    echo "== Modo Docker =="

    # El contenedor de base crea la DB y aplica el schema en su primer
    # arranque (montado en /docker-entrypoint-initdb.d). Aqui solo lo
    # re-aplicamos si el contenedor ya esta corriendo.
    if docker compose ps db >/dev/null 2>&1; then
        docker compose exec -T db \
            psql -U "${DB_USER}" -d "${DB_NAME}" \
                -f /docker-entrypoint-initdb.d/schema.sql
        echo "Schema aplicado dentro del contenedor 'db'."
    else
        echo "El contenedor 'db' no esta corriendo."
        echo "Levantalo primero con: scripts/start.sh"
        echo "(En su primer arranque 'db' crea la DB y aplica el schema solo)."
    fi
else
    echo "== Modo local =="

    # Comando SQL que se ejecuta como superusuario postgres.
    # Se elige entre PGPASSWORD_SUPERUSER (si esta definida) o sudo -u postgres.
    run_super() {
        if [[ -n "${PGPASSWORD_SUPERUSER:-}" ]]; then
            PGPASSWORD="${PGPASSWORD_SUPERUSER}" \
                psql -U postgres -h "${DB_HOST}" -p "${DB_PORT}" "$@"
        else
            sudo -u postgres psql "$@"
        fi
    }

    echo "Comprobando acceso como superusuario postgres..."
    run_super -c "SELECT 1" >/dev/null

    echo "Creando rol '${DB_USER}' si no existe..."
    run_super \
        -c "DO \$\$ BEGIN
                IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
                    CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASSWORD}';
                END IF;
            END \$\$;"
    run_super \
        -c "ALTER ROLE ${DB_USER} WITH LOGIN PASSWORD '${DB_PASSWORD}';"

    echo "Creando base '${DB_NAME}' si no existe..."
    if ! run_super -lqt | cut -d '|' -f 1 | grep -qw "${DB_NAME}"; then
        run_super -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
    fi

    echo "Aplicando schema (${SCHEMA})..."
    PGPASSWORD="${DB_PASSWORD}" psql -U "${DB_USER}" -h "${DB_HOST}" \
        -p "${DB_PORT}" -d "${DB_NAME}" -f "${SCHEMA}"

    echo "Transfiriendo propiedad del schema public a '${DB_USER}'..."
    run_super -d "${DB_NAME}" \
        -c "DO \$\$
            DECLARE r record;
            BEGIN
                FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='public' LOOP
                    EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename)
                        || ' OWNER TO ' || quote_ident('${DB_USER}');
                END LOOP;
                FOR r IN SELECT sequence_name FROM information_schema.sequences
                          WHERE sequence_schema='public' LOOP
                    EXECUTE 'ALTER SEQUENCE public.' || quote_ident(r.sequence_name)
                        || ' OWNER TO ' || quote_ident('${DB_USER}');
                END LOOP;
            END \$\$;"

    echo "Asegurando permisos para '${DB_USER}' sobre el schema public..."
    run_super -d "${DB_NAME}" -c "GRANT USAGE, CREATE ON SCHEMA public TO ${DB_USER};"
    run_super -d "${DB_NAME}" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DB_USER};"
    run_super -d "${DB_NAME}" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${DB_USER};"
    run_super -d "${DB_NAME}" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${DB_USER};"
    run_super -d "${DB_NAME}" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${DB_USER};"

    echo "Base de datos lista: ${DB_NAME} (usuario ${DB_USER})"
fi
