Desarrollar una aplicación web que permita la inscripción de alumnos a carreras, con una parte pública y una parte privada (ABM).

Parte privada (ABM)
No requiere login (proteger con .htaccess).

Permite:

Si un alumno ya está inscripto, debe mostrarse un error.

Alta, baja y modificación de alumnos.

Asignar una carrera a cada alumno.

Parte pública
Formulario de inscripción donde el alumno:

Si el alumno ya está inscripto, debe mostrarse un error.

Ingresa nombre, email, teléfono y nacionalidad.

Elige una carrera.

Datos
Alumno: nombre, email, teléfono, nacionalidad.

Carrera: nombre.

Requisitos técnicos
Backend: Perl

Frontend: HTML / JavaScript

Base de datos: PostgreSQL

Separar frontend, backend y acceso a datos.

Diseño responsive básico.

Entrega
Código (repo o .zip).

Script SQL.

README con pasos para ejecutarlo.

Requisitos: - Perl 5 con módulos: DBI, DBD::Pg, CGI, JSON::PP - PostgreSQL - Servidor web con soporte CGI (Apache recomendado)

1. Configurar las credenciales en .env (copiar desde .env.example):

   cp .env.example .env

2. Preparar la base (crea rol + base + aplica sql/schema.sql, idempotente):

   scripts/setup-db.sh

3. Arrancar (detecta Docker si está disponible, sino modo local):

   scripts/start.sh

4. Acceder:
   - Parte pública (formulario de inscripción):
     local: /student-crud/
     docker: /
   - Parte privada (ABM, protegida por .htaccess):
     local: /student-crud/admin
     docker: /admin

Estructura de tablas (3 tablas, 1 estudiante -> 1 carrera):

    carreras (id, nombre, codigo)
    estudiantes (id, nombre, apellido, dni UNIQUE, email UNIQUE, ...)
    inscripciones (id, estudiante_id UNIQUE -> estudiantes.id,
                   carrera_id -> carreras.id)

La restricción UNIQUE sobre inscripciones.estudiante_id garantiza que
un estudiante solo pueda estar inscripto en una única carrera, mientras
que una carrera puede tener muchos estudiantes.

Borrado en cascada:

- Al borrar un estudiante -> se borran sus inscripciones (CASCADE).
- Al borrar una carrera -> se borran sus inscripciones (CASCADE).

El esquema definitivo es UN SOLO archivo: sql/schema.sql (ya incluye el
ON DELETE CASCADE y la restricción UNIQUE). No hay migración aparte.

Regla de negocio (inscripción de un estudiante a otra carrera):

- Si un estudiante ya está inscripto en una carrera y se intenta
  inscribir en OTRA, el backend responde 409 con el mensaje:
  "No se puede inscribir a otra carrera: el estudiante ya está
  inscripto en '<nombre de la carrera actual>'."
- Si intenta inscribirse en la MISMA carrera, responde 409 con:
  "El estudiante ya está inscripto en esta carrera."
