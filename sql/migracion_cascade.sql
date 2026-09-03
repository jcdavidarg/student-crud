-- ============================================================
-- Migración: ON DELETE CASCADE en inscripciones.carrera_id
--
-- Ejecutar SOLO si ya creaste el schema con la versión anterior
-- donde carrera_id tenía ON DELETE RESTRICT.
--
-- Antes de ejecutar, la constraint se llama
-- inscripciones_carrera_id_fkey (nombre por defecto de PostgreSQL).
-- Este script la elimina y la vuelve a crear con ON DELETE CASCADE,
-- de modo que al borrar una carrera se borren sus inscripciones.
-- ============================================================

ALTER TABLE inscripciones
    DROP CONSTRAINT IF EXISTS inscripciones_carrera_id_fkey;

ALTER TABLE inscripciones
    ADD CONSTRAINT inscripciones_carrera_id_fkey
    FOREIGN KEY (carrera_id)
    REFERENCES carreras(id)
    ON DELETE CASCADE;
