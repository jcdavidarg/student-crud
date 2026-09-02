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



1 ARQUITECTURA

┌─────────────────────────────┐
│           FRONT             │
│      HTML + CSS + JS        │
│                             │
│      /public                │
└──────────────┬──────────────┘
               │ HTTP / JSON
               ▼
┌─────────────────────────────┐
│           BACK              │
│           Perl              │
│      REST API / CGI         │
│                             │
│      /api                   │
└──────────────┬──────────────┘
               │ DBI
               ▼
┌─────────────────────────────┐
│        PostgreSQL           │
│                             │
│ estudiantes                 │
│ materias                    │
│ inscripciones               │
└─────────────────────────────┘

2 NODELADO DB

ESTUDIANTE
    │
    │ 1
    │
    │ N
INSCRIPCION
    │
    │ N
    │
    │ 1
MATERIA



2 ESTRUCTURA DE CARPETAS

student-crud/
│
├── public/
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── app.js
│
├── cgi-bin/
│   └── api/
│       └── students.pl
│
├── lib/
│   ├── DB.pm
│   ├── Student.pm
│   └── Response.pm
│
├── sql/
│   └── schema.sql
│
└── config/
    └── database.conf


public → frontend

cgi-bin → endpoints

lib → lógica

sql → base de datos

config → configuración


3 RESPONSABILIDADES

                  HTTP
                   │
                   ▼
            cgi-bin/students.pl
                   │
                   ▼
             Student.pm
            (negocio/modelo)
                   │
                   ▼
                DB.pm
          (acceso a PostgreSQL)
                   │
                   ▼
              PostgreSQL




Frontend
   ↓
HTTP
   ↓
Endpoint Perl
   ↓
Validación
   ↓
Lógica de negocio
   ↓
Acceso a DB
   ↓
PostgreSQL



4 INSTALACIÓN Y EJECUCIÓN

Requisitos:
    - Perl 5 con módulos: DBI, DBD::Pg, CGI, JSON::PP
    - PostgreSQL
    - Servidor web con soporte CGI (Apache recomendado)

1. Crear la base de datos:

       sudo -u postgres createdb students_db

2. Crear el usuario y darle permisos:

       sudo -u postgres psql -c "
         CREATE USER students_user WITH PASSWORD 'students123';
         GRANT ALL PRIVILEGES ON DATABASE students_db TO students_user;
       "

3. Ejecutar el schema:

       psql -h localhost -U students_user -d students_db -f sql/schema.sql

4. Configurar las credenciales:

   El archivo lib/DB.pm contiene la conexión (dbname=students_db,
   usuario=students_user, password=students123). Si tus credenciales
   difieren, actualizalas ahí.

5. Servir la aplicación:

   Si usás Apache con CGI habilitado, el .htaccess redirige:
       /  -> public/index.html
       /admin -> public/admin/index.html
       /students, /carreras, /inscripciones -> cgi-bin

   Asegurate de que se cargue el módulo rewrite (a2enmod rewrite).

6. Acceder:

   - Parte pública (formulario de inscripción): /
   - Parte privada (ABM): /admin (protegida por .htaccess)

Estructura de tablas (3 tablas, 1 estudiante -> 1 carrera):

    carreras (id, nombre, codigo)
    estudiantes (id, nombre, apellido, dni UNIQUE, email UNIQUE, ...)
    inscripciones (id, estudiante_id UNIQUE -> estudiantes.id,
                   carrera_id -> carreras.id)

   La restricción UNIQUE sobre inscripciones.estudiante_id garantiza que
   un estudiante solo pueda estar inscripto en una única carrera, mientras
   que una carrera puede tener muchos estudiantes.


