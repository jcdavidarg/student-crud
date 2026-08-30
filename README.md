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


