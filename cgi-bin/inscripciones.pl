#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CGI;
use DB;
use StudentRepository;
use MateriaRepository;
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

my $materia_repository = MateriaRepository->new($dbh);

my $inscripcion_repository = InscripcionRepository->new($dbh);

my $service =
  InscripcionService->new($inscripcion_repository, $student_repository,
    $materia_repository);


sub send_json {
    my ($status, $data) = @_;

    print "Status: $status\n";
    print "Content-Type: application/json\n\n";
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
      materia_id
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

    if ($inscripcion->{materia_id} !~ /^\d+$/) {
        return {
            valid => 0,
            error => "El materia_id debe ser numerico"
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

    my $inscripcion;

    eval { $inscripcion = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    my $validation = validate_inscripcion($inscripcion);

    unless ($validation->{valid}) {
        send_error("400 Bad Request", $validation->{error});
        exit;
    }

    my $result = $service->create_inscripcion($inscripcion->{estudiante_id},
        $inscripcion->{materia_id});

    if (!$result->{success}) {

        if ($result->{reason} eq 'student_not_found') {

            send_json(
                "404 Not Found",
                {
                    error => "Estudiante no encontrado"
                }
            );
            exit;
        }

        if ($result->{reason} eq 'materia_not_found') {

            send_json(
                "404 Not Found",
                {
                    error => "Materia no encontrada"
                }
            );
            exit;
        }

        if ($result->{reason} eq 'inscripcion_already_exists') {

            send_json(
                "409 Conflict",
                {
                    error => "El estudiante ya esta inscripto en esta materia"
                }
            );
            exit;
        }

        if ($result->{reason} eq 'database_error') {

            send_json(
                "500 Internal Server Error",
                {
                    error => "Error interno de base de datos"
                }
            );
            exit;
        }
    }

    send_json("201 Created", $result->{inscripcion});
}
elsif ($method eq 'DELETE') {

    my $id = $cgi->url_param('id');

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
