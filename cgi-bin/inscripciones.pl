#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CGI;
use DB;
use StudentRepository;
use CarreraRepository;
use InscripcionRepository;
use InscripcionService;
use JSON::PP;

my $method = $ENV{'REQUEST_METHOD'} || '';

my $body = '';

if ($method eq 'POST') {
    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;
    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

my $dbh = DB::connect();

my $student_repository = StudentRepository->new($dbh);

my $carrera_repository = CarreraRepository->new($dbh);

my $inscripcion_repository = InscripcionRepository->new($dbh);

my $service =
  InscripcionService->new($inscripcion_repository, $student_repository,
    $carrera_repository);


sub send_json {
    my ($status, $data) = @_;

    print "Status: $status\n";
    print "Content-Type: application/json; charset=utf-8\n\n";
    print encode_json($data);
}


sub send_error {
    my ($status, $message) = @_;

    send_json(
        $status,
        {
            error => $message
        }
    );
}


sub validate_inscripcion {
    my ($inscripcion) = @_;

    my @required_fields = qw(
      estudiante_id
      carrera_id
    );

    foreach my $field (@required_fields) {
        if (!defined $inscripcion->{$field}
            || $inscripcion->{$field} eq '')
        {
            return {
                valid => 0,
                error => "El campo '$field' es obligatorio"
            };
        }
    }

    if ($inscripcion->{estudiante_id} !~ /^\d+$/) {
        return {
            valid => 0,
            error => "El estudiante_id debe ser numerico"
        };
    }

    if ($inscripcion->{carrera_id} !~ /^\d+$/) {
        return {
            valid => 0,
            error => "El carrera_id debe ser numerico"
        };
    }

    return { valid => 1 };
}


if ($method eq 'GET') {

    my $id = $cgi->param('id');

    if (defined $id) {

        my $inscripcion = $service->get_inscripcion($id);

        if (!$inscripcion) {
            send_error("404 Not Found", "Inscripcion no encontrada");
            exit;
        }

        send_json("200 OK", $inscripcion);
    }
    else {

        my $inscripciones = $service->get_inscripciones();

        send_json("200 OK", $inscripciones);
    }
}
elsif ($method eq 'POST') {

    my $data;

    eval { $data = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    # ============================================================
    # INSCRIPCION PUBLICA
    # ============================================================
    #
    # El frontend publico envia los datos del estudiante
    # y la carrera. El backend se encarga de resolver
    # estudiante_id.
    #
    if (   exists $data->{nombre}
        || exists $data->{apellido}
        || exists $data->{dni}
        || exists $data->{email})
    {

        # Validar datos minimos del estudiante
        my @required_student_fields = qw(
          nombre
          apellido
          dni
          email
        );

        foreach my $field (@required_student_fields) {

            if (!defined $data->{$field}
                || $data->{$field} eq '')
            {
                send_error("400 Bad Request",
                    "El campo '$field' es obligatorio");
                exit;
            }
        }

        # Validar carrera
        if (!defined $data->{carrera_id}
            || $data->{carrera_id} eq '')
        {
            send_error("400 Bad Request",
                "El campo 'carrera_id' es obligatorio");
            exit;
        }

        if ($data->{carrera_id} !~ /^\d+$/) {
            send_error("400 Bad Request", "El carrera_id debe ser numerico");
            exit;
        }

        # Validar DNI
        if ($data->{dni} !~ /^\d{8}$/) {
            send_error("400 Bad Request", "El DNI debe contener 8 digitos");
            exit;
        }

        # Validar email
        if ($data->{email} !~ /^[^@\s]+@[^@\s]+\.[^@\s]+$/) {
            send_error("400 Bad Request", "El email no es valido");
            exit;
        }

        my $student_data = {
            nombre       => $data->{nombre},
            apellido     => $data->{apellido},
            dni          => $data->{dni},
            email        => $data->{email},
            telefono     => $data->{telefono},
            nacionalidad => $data->{nacionalidad}
        };

        my $result =
          $service->create_inscripcion_publica($student_data,
            $data->{carrera_id});

        if (!$result->{success}) {

            if ($result->{reason} eq 'carrera_not_found') {

                send_error("404 Not Found", "Carrera no encontrada");
                exit;
            }

            if ($result->{reason} eq 'dni_email_conflict') {

                send_error("409 Conflict",
                    "El DNI y el email pertenecen a estudiantes diferentes");
                exit;
            }

            if ($result->{reason} eq 'inscripcion_already_exists') {

                send_error("409 Conflict",
                    "El estudiante ya está inscripto en esta carrera.");
                exit;
            }

            if ($result->{reason} eq 'inscripcion_en_otra_carrera') {

                my $nombre_carrera = $result->{carrera}->{nombre} || 'otra carrera';

                send_error("409 Conflict",
                    "No se puede inscribir a otra carrera: el estudiante ya está inscripto en '$nombre_carrera'.");
                exit;
            }

            if ($result->{reason} eq 'database_error') {

                send_error(
                    "500 Internal Server Error",
                    "Error interno de base de datos"
                );
                exit;
            }

            send_error("500 Internal Server Error", "Error interno");
            exit;
        }

        send_json("201 Created", $result->{inscripcion});
    }

    # ============================================================
    # INSCRIPCION ADMINISTRATIVA
    # ============================================================
    #
    # El admin sigue enviando:
    #
    # {
    #     estudiante_id: 1,
    #     carrera_id: 2
    # }
    #
    else {

        my $validation = validate_inscripcion($data);

        unless ($validation->{valid}) {
            send_error("400 Bad Request", $validation->{error});
            exit;
        }

        my $result = $service->create_inscripcion($data->{estudiante_id},
            $data->{carrera_id});

        if (!$result->{success}) {

            if ($result->{reason} eq 'student_not_found') {

                send_error("404 Not Found", "Estudiante no encontrado");
                exit;
            }

            if ($result->{reason} eq 'carrera_not_found') {

                send_error("404 Not Found", "Carrera no encontrada");
                exit;
            }

            if ($result->{reason} eq 'inscripcion_already_exists') {

                send_error("409 Conflict",
                    "El estudiante ya está inscripto en esta carrera.");
                exit;
            }

            if ($result->{reason} eq 'inscripcion_en_otra_carrera') {

                my $nombre_carrera = $result->{carrera}->{nombre} || 'otra carrera';

                send_error("409 Conflict",
                    "No se puede inscribir a otra carrera: el estudiante ya está inscripto en '$nombre_carrera'.");
                exit;
            }

            if ($result->{reason} eq 'database_error') {

                send_error(
                    "500 Internal Server Error",
                    "Error interno de base de datos"
                );
                exit;
            }
        }

        send_json("201 Created", $result->{inscripcion});
    }
}

elsif ($method eq 'DELETE') {

    my $id = $cgi->param('id');

    unless (defined $id) {

        send_error("400 Bad Request", "El id es obligatorio");
        exit;
    }

    my $result = $service->delete_inscripcion($id);

    if (!$result->{success}) {

        if ($result->{reason} eq 'inscripcion_not_found') {

            send_error("404 Not Found", "Inscripcion no encontrada");
            exit;
        }

        if ($result->{reason} eq 'database_error') {

            send_error(
                "500 Internal Server Error",
                "Error interno de base de datos"
            );
            exit;
        }
    }

    send_json("200 OK", $result->{inscripcion});
}
else {

    send_error("405 Method Not Allowed", "Metodo HTTP no soportado");
}


$dbh->disconnect();
