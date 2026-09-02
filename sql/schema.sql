-- ============================================================
-- Schema de base de datos - Inscripcion a carreras
-- PostgreSQL
--
-- Modelo:
--   1 estudiante -> 1 carrera (a traves de la tabla inscripciones)
--   1 carrera    -> N estudiantes
--
-- La tabla intermedia inscripciones garantiza con UNIQUE(estudiante_id)
-- que un estudiante solo pueda estar inscripto en una unica carrera.
-- ============================================================

-- ------------------------------------------------------------
-- Tabla: carreras
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS carreras (
    id      SERIAL PRIMARY KEY,
    nombre  VARCHAR(150) NOT NULL,
    codigo  VARCHAR(20)  NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Tabla: estudiantes
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estudiantes (
    id            SERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    apellido      VARCHAR(100) NOT NULL,
    dni           VARCHAR(8)   NOT NULL UNIQUE,
    email         VARCHAR(150) NOT NULL UNIQUE,
    nacionalidad  VARCHAR(100),
    telefono      VARCHAR(30),
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Tabla: inscripciones (tabla intermedia)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inscripciones (
    id                SERIAL PRIMARY KEY,
    estudiante_id     INTEGER     NOT NULL UNIQUE REFERENCES estudiantes(id) ON DELETE CASCADE,
    carrera_id        INTEGER     NOT NULL REFERENCES carreras(id) ON DELETE RESTRICT,
    fecha_inscripcion TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indices utiles para las busquedas mas frecuentes
CREATE INDEX IF NOT EXISTS idx_inscripciones_carrera
    ON inscripciones (carrera_id);

-- ------------------------------------------------------------
-- Datos semilla (opcional)
-- ------------------------------------------------------------
INSERT INTO carreras (nombre, codigo)
VALUES
    ('Ingenieria en Sistemas', 'IS'),
    ('Licenciatura en Economia', 'ECO'),
    ('Diseño Grafico', 'DG')
ON CONFLICT (codigo) DO NOTHING;
