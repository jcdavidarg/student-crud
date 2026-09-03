# Inscripción a Carreras

Aplicación web para la **inscripción de alumnos a carreras universitarias**.
Tiene una **parte pública** (formulario de inscripción) y una **parte privada**
(panel de administración ABM: alta, baja y modificación de estudiantes,
carreras e inscripciones).

- **Backend:** Perl (REST API vía CGI)
- **Frontend:** HTML / CSS / JavaScript
- **Base de datos:** PostgreSQL 16
- **Servidor:** Apache con soporte CGI

---

## Tabla de contenidos

1. [Arquitectura](#arquitectura)
2. [Lógica de negocio](#lógica-de-negocio)
3. [Modelo de datos](#modelo-de-datos)
4. [Estructura del proyecto](#estructura-del-proyecto)
5. [Configuración (`.env`)](#configuración-env)
6. [Ejecución: modo local (sin Docker)](#ejecución-modo-local-sin-docker)
7. [Ejecución: modo Docker](#ejecución-modo-docker)
8. [Coexistencia de los dos modos (puertos)](#coexistencia-de-los-dos-modos-puertos)
9. [Endpoints de la API](#endpoints-de-la-api)
10. [Scripts](#scripts)

---

## Arquitectura

La aplicación sigue una **arquitectura por capas** con la intención de
**separar responsabilidades**: cada capa se ocupa de una única cosa, y las
capas se comunican de forma desacoplada.

```
┌──────────────────────────────────────────────────────────────┐
│  PRESENTACIÓN / FRONTEND                                      │
│  public/  (HTML + CSS + JS)                                   │
│    · publico: index.html + js/public.js                       │
│    · admin:  admin/index.html + js/admin.js                   │
└──────────────────────────┬───────────────────────────────────┘
                           │ HTTP (fetch) + JSON
┌──────────────────────────▼───────────────────────────────────┐
│  CAPA DE ENTRADA / ENDPOINTS (HTTP)                           │
│  cgi-bin/*.pl  ->  students.pl, carreras.pl, inscripciones.pl │
│    · parsea el request (query string + body JSON)             │
│    · valida datos de entrada                                  │
│    · delega en el servicio y traduce respuestas a HTTP        │
└──────────────────────────┬───────────────────────────────────┘
                           │ llamadas de negocio
┌──────────────────────────▼───────────────────────────────────┐
│  CAPA DE NEGOCIO / SERVICIOS                                  │
│  lib/*Service.pm -> StudentService, CarreraService,           │
│                     InscripcionService                        │
│    · reglas de negocio (unicidad, una carrera por alumno)     │
│    · no conoce nada de HTTP ni de SQL                         │
└──────────────────────────┬───────────────────────────────────┘
                           │ acceso a datos
┌──────────────────────────▼───────────────────────────────────┐
│  CAPA DE ACCESO A DATOS / REPOSITORIOS                        │
│  lib/*Repository.pm -> StudentRepository, CarreraRepository,  │
│                        InscripcionRepository                  │
│    · queries SQL (solo SQL, sin reglas de negocio)            │
└──────────────────────────┬───────────────────────────────────┘
                           │ DBI
┌──────────────────────────▼───────────────────────────────────┐
│  INFRAESTRUCTURA                                              │
│  lib/DB.pm (conexión) + lib/Config.pm (configuración)         │
│  PostgreSQL (students_db)                                     │
└──────────────────────────────────────────────────────────────┘
```

### Por qué esta separación de responsabilidades

- **Endpoints** (`cgi-bin/*.pl`) solo se encargan de *entrada y salida HTTP*:
  leen el request, validan el formato y devuelven el código de estado y el
  JSON. No tienen reglas de negocio.
- **Servicios** (`*Service.pm`) concentran toda la **lógica de negocio**
  (unicidad de DNI/email/código, una sola carrera por estudiante, mensajes de
  error). No saben cómo se recibe el request ni cómo se guardan los datos.
- **Repositorios** (`*Repository.pm`) aíslan todo el **SQL**. Si mañana se
  cambia de base de datos o se cambia el estilo de las queries, solo se tocan
  los repositorios.
- **Modelo/entidad** (`Student.pm`) representa un objeto de dominio simple.
- **Infraestructura** (`DB.pm` / `Config.pm`) centraliza la conexión y la
  configuración, evitando credenciales y detalles esparcidos por el código.

Esto da como resultado un código **testeable** (se puede probar un servicio
con un repositorio falso), **mantenible** y **independiente de la tecnología**:
por ejemplo, cambiar el frontend o pasar de Apache a otro servidor no afecta a
la lógica de negocio ni a la base de datos.

---

## Lógica de negocio

La regla central del sistema: **un estudiante se inscribe en una única
carrera** a la vez. Está respaldada a nivel de base de datos por la restricción
`UNIQUE(estudiante_id)` sobre `inscripciones` y verificada por el servicio.

### Panel administrativo (`/admin`)

- **Estudiantes** (CRUD):
  - `POST /students` crea un estudiante. El **DNI** y el **email** son únicos:
    si el DNI ya existe → `409 (student_exists)`; si el email ya existe →
    `409 (email_already_exists)`.
  - `PUT /students?id=` actualiza. Si el DNI o el email que se asignan ya
    pertenecen a otro estudiante → `409 (dni_already_exists /
    email_already_exists)`.
  - `DELETE /students?id=` borra (sus inscripciones se borran en cascada).
  - `GET /students` lista; `GET /students?id|dni|email=` consulta por id,
    DNI o email.
- **Carreras** (CRUD):
  - El **código** es único (`409 codigo_already_exists`).
  - `GET /carreras`, `GET /carreras?id=`, `POST`, `PUT?id=`, `DELETE?id=`.
- **Inscripciones**:
  - `POST /inscripciones` asocia un `estudiante_id` con una `carrera_id`.
    - Si el estudiante ya está en esa misma carrera → `409
      (inscripcion_already_exists)`.
    - Si el estudiante ya está en **otra** carrera → `409
      (inscripcion_en_otra_carrera)` con el mensaje:
      *"No se puede inscribir a otra carrera: el estudiante ya está inscripto
      en '<carrera actual>'."*
    - Si el estudiante o la carrera no existen → `404`.
  - `GET /inscripciones` lista con estudiante y carrera resueltos;
    `GET /inscripciones?id=`, `DELETE?id=`.

### Formulario público (`/`)

`POST /inscripciones` recibe los **datos del estudiante** + `carrera_id`.
El backend resuelve la inscripción. **Comportamiento actual:**

1. Verifica que la carrera exista (si no → `404 carrera_not_found`).
2. Verifica que el **DNI no exista** ya como estudiante (si existe → `409
   dni_already_exists`).
3. Verifica que el **email no exista** ya como estudiante (si existe → `409
   email_already_exists`).
4. Si DNI y email son **nuevos**, crea el estudiante y su inscripción → `201
   Created`.

> Se permite **solo la inscripción de estudiantes nuevos**: si el DNI o el
> email ya están registrados, no se crea ni se modifica nada, y se devuelve
> un error de conflicto.

---

## Modelo de datos

El esquema definitivo está en **`sql/schema.sql`** (único archivo de esquema).

```
carreras (id, nombre, codigo UNIQUE, created_at, updated_at)
estudiantes (id, nombre, apellido, dni UNIQUE, email UNIQUE,
             nacionalidad, telefono, created_at, updated_at)
inscripciones (id, estudiante_id UNIQUE -> estudiantes.id ON DELETE CASCADE,
               carrera_id -> carreras.id ON DELETE CASCADE,
               fecha_inscripcion)
```

- `inscripciones.estudiante_id` es `UNIQUE`: un estudiante en una sola carrera.
- `ON DELETE CASCADE`: al borrar un estudiante o una carrera se borran sus
  inscripciones automáticamente.
- El schema incluye datos semilla de carreras (opcional) y crea índices.

No existe migración ni schema secundario: **`sql/schema.sql` es la única
fuente de verdad** para la estructura de la base.

---

## Estructura del proyecto

```
student-crud/
├── .env.example           # plantilla de configuración (versionada)
├── .env                   # configuración real (NO versionada)
├── .gitignore
├── .htaccess              # reglas de reescritura (front + API)
├── Dockerfile             # imagen Apache + Perl + DBD::Pg
├── docker-compose.yml     # servicios app + db
├── README.md
├── anotaciones.md         # notas internas de la persona desarrolladora
├── public/                # frontend
│   ├── index.html         # formulario público
│   ├── admin/index.html   # panel administrativo
│   ├── css/styles.css
│   └── js/{public,admin}.js
├── cgi-bin/               # endpoints REST (capa de entrada)
│   ├── students.pl
│   ├── carreras.pl
│   └── inscripciones.pl
├── lib/                   # lógica y acceso a datos
│   ├── Student.pm              # entidad / modelo
│   ├── StudentService.pm       # negocio estudiantes
│   ├── StudentRepository.pm    # SQL estudiantes
│   ├── CarreraService.pm       # negocio carreras
│   ├── CarreraRepository.pm    # SQL carreras
│   ├── InscripcionService.pm   # negocio inscripciones
│   ├── InscripcionRepository.pm# SQL inscripciones
│   ├── Config.pm               # lee el .env
│   └── DB.pm                   # conexión a PostgreSQL
├── sql/
│   └── schema.sql          # esquema definitivo
├── scripts/                # utilidades de arranque
│   ├── setup-db.sh
│   ├── start.sh
│   └── stop.sh
└── docker/
    └── apache-site.conf    # vhost Apache para el contenedor
```

---

## Configuración (`.env`)

Toda la configuración sensible está centralizada en el archivo **`.env`**
(que **no** se sube al repositorio). Se crea copiando la plantilla:

```bash
cp .env.example .env
# luego editá los valores si hace falta
```

Contenido:

```dotenv
DB_HOST=localhost      # en docker se sobreescribe a "db"
DB_PORT=5432
DB_NAME=students_db
DB_USER=students_user
DB_PASSWORD=students123
APP_PORT=80            # puerto HTTP
```

> La conexión se construye en `lib/DB.pm` a partir de estas variables.
> Si una variable también está presente como **variable de entorno del
> sistema**, esta última tiene prioridad sobre el `.env` (útil en Docker).

---

## Ejecución: modo local (sin Docker)

### 1. Instalar dependencias

Requisitos: **PostgreSQL 16**, **Apache 2.4** (con `mod_cgi` y `mod_rewrite`),
y **Perl 5** con los módulos `DBI`, `DBD::Pg`, `CGI` y `JSON::PP`.

En Ubuntu / Debian:

```bash
# PostgreSQL
sudo apt update
sudo apt install -y postgresql postgresql-client

# Apache + CGI + rewrite
sudo apt install -y apache2
sudo a2enmod cgi rewrite

# Perl y módulos de la app
sudo apt install -y perl libdbi-perl libdbd-pg-perl libcgi-pm-perl libjson-pp-perl
```

Para validar los módulos Perl:

```bash
perl -e 'use DBI; use DBD::Pg; use CGI; use JSON::PP; print "OK\n"'
```

### 2. Configurar el entorno

```bash
cp .env.example .env
```

### 3. Preparar la base de datos

Crea el usuario, la base y aplica `sql/schema.sql` (idempotente):

```bash
scripts/setup-db.sh local
```

> Precisa acceso como superusuario `postgres`. Si tu instalación de PostgreSQL
> no permite `sudo -u postgres`, definí una variable de entorno con la password
> del superusuario:
> ```bash
> PGPASSWORD_SUPERUSER="tu_password_de_postgres" scripts/setup-db.sh local
> ```

### 4. Configurar Apache

Creá un alias para servir la app (dado que el frontend usa la subruta
`/student-crud`). Por ejemplo, en
`/etc/apache2/conf-available/student-crud.conf`:

```apache
Alias /student-crud/ /ruta/a/student-crud/

<Directory "/ruta/a/student-crud">
    AllowOverride All
    Options Indexes FollowSymLinks ExecCGI
    Require all granted
    AddHandler cgi-script .pl
    DirectoryIndex public/index.html
</Directory>
```

Habilitar y recargar:

```bash
sudo a2enconf student-crud
sudo systemctl reload apache2   # o: sudo service apache2 reload
```

> El `.htaccess` del proyecto reescribe `/`, `/css/*`, `/js/*`, `/admin` y los
> endpoints `/students`, `/carreras`, `/inscripciones` hacia `public/` y
> `cgi-bin/`.

### 5. Arrancar

```bash
scripts/start.sh local
```

ó, si ya tenés PostgreSQL y Apache corriendo, solo configurá la base y accedé.

### 6. Acceder

- Parte pública (formulario de inscripción): `http://localhost/student-crud/`
- Panel administrativo: `http://localhost/student-crud/admin`

---

## Ejecución: modo Docker

Requisitos: **Docker** y **Docker Compose** instalados y corriendo.

### 1. Configurar el entorno

```bash
cp .env.example .env
```

El contenedor `db` crea el usuario/base y aplica `sql/schema.sql`
automáticamente en su primer arranque (el archivo se monta en
`/docker-entrypoint-initdb.d`).

### 2. Levantar

```bash
scripts/start.sh docker
# o directamente:
# docker compose up -d --build
```

En el primer arranque la base se inicializa (puede tardar unos segundos).

### 3. Acceder

La app se publica en el puerto configurado en `APP_PORT` (por defecto `8080`,
para no chocar con el Apache local que usa el puerto 80):

- Parte pública: `http://localhost:8080/`
- Panel administrativo: `http://localhost:8080/admin`

> En Docker la app se sirve en la **raíz `/`** (a diferencia del modo local,
> que usa `/student-crud`). El `API_BASE` del frontend se calcula de forma
> dinámica, por lo que funciona en ambos modos sin tocar código.

### 4. Detener / reiniciar

```bash
scripts/stop.sh            # docker compose down (mantiene la data)
scripts/stop.sh && docker compose down -v   # borra también la data de la DB
docker compose logs -f     # ver logs
```

---

## Coexistencia de los dos modos (puertos)

Los modos **local** y **Docker** pueden correr **al mismo tiempo** sin chocar.

| Modo       | Comando             | Puerto HTTP | URL de acceso                                                                 |
|------------|---------------------|-------------|-------------------------------------------------------------------------------|
| Local      | `scripts/start.sh local`  | `80`        | `http://localhost/student-crud/`                                          |
| Docker     | `scripts/start.sh docker` | `8080`      | `http://localhost:8080/` (raíz `/` y `/admin`)                            |

Detalles clave:

- **HTTP**: Docker usa el puerto `APP_PORT` de `.env` (por defecto `8080`), así que
  no compite con el Apache local (puerto `80`). Si tu Apache local no usa el 80
  lo podés ajustar en `.env`.
- **Base de datos**: el contenedor `db` **no expone** el `5432` al host (la app
  se conecta por la red interna de Docker), por lo que no choca con un
  PostgreSQL local que pudiera estar escuchando en `5432`.
- **Datasets independientes**: la DB local y la DB del contenedor son **bases
  separadas**. Los datos que cargues en un modo no aparecen en el otro.
- **Alternar entre modos**: subís uno con su `start.sh` y lo bajás con su
  `stop.sh`. No hace falta apagar el otro.
  - Si no estás usando Docker, `scripts/stop.sh` baja el stack Docker y liberás
    el 8080.
  - Si no usás el modo local, no es necesario tener Apache/PostgreSQL locales
    activos.

---

## Endpoints de la API

Ruta de acceso según el modo: local → `/student-crud<ruta>`, docker → `<ruta>`.

| Método | Ruta          | Body                            | Respuestas                                                                          |
|--------|---------------|---------------------------------|-------------------------------------------------------------------------------------|
| GET    | `/students`   | —                               | 200 lista de estudiantes                                                            |
| GET    | `/students?id=` | —                             | 200 estudiante / 404                                                                 |
| GET    | `/students?dni=` | —                           | 200 estudiante / 404                                                                 |
| GET    | `/students?email=` | —                         | 200 estudiante / 404                                                                 |
| POST   | `/students`   | estudiante (nombre, apellido, dni, email, [telefono], [nacionalidad]) | 201 / 409 (student_exists, email_already_exists) |
| PUT    | `/students?id=` | estudiante                  | 200 / 404 / 409 (dni_already_exists, email_already_exists)                          |
| DELETE | `/students?id=` | —                          | 200 / 404                                                                           |
| GET    | `/carreras`   | —                               | 200 lista de carreras                                                               |
| GET    | `/carreras?id=` | —                            | 200 carrera / 404                                                                    |
| POST   | `/carreras`   | carrera (nombre, codigo)         | 201 / 409 (codigo_already_exists)                                                   |
| PUT    | `/carreras?id=` | carrera                      | 200 / 404 / 409 (codigo_already_exists)                                            |
| DELETE | `/carreras?id=` | —                          | 200 / 404                                                                           |
| GET    | `/inscripciones` | —                          | 200 lista (estudiante + carrera resueltos)                                         |
| GET    | `/inscripciones?id=` | —                     | 200 / 404                                                                            |
| POST   | `/inscripciones` | admin: `estudiante_id`, `carrera_id`; público: datos de estudiante + `carrera_id` | 201 / 404 (student_not_found, carrera_not_found) / 409 (inscripcion_already_exists, inscripcion_en_otra_carrera, dni_already_exists, email_already_exists) |
| DELETE | `/inscripciones?id=` | —                   | 200 / 404                                                                           |

Formato de respuesta de error:

```json
{ "success": 0, "reason": "motivo_interno" }
```

o, en los errores HTTP de los endpoints:

```json
{ "error": "Descripción para el usuario" }
```

---

## Scripts

Todos los scripts están en `scripts/` y son ejecutables.

| Script          | Descripción                                                                 |
|-----------------|-----------------------------------------------------------------------------|
| `setup-db.sh`   | Crea rol + base + permisos y aplica `sql/schema.sql` (idempotente).          |
| `start.sh`      | Levanta la aplicación: detecta Docker si está disponible, o arranca local.  |
| `stop.sh`       | Detiene la aplicación. En modo local acepta `-pg` para detener PostgreSQL.  |

Modo automático: los scripts usan Docker si el comando `docker` responde; si
no, operan en modo local. Podés forzar el modo pasando `docker` o `local` como
primer argumento.
