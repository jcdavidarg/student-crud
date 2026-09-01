#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CGI;
use DB;
use MateriaRepository;
use MateriaService;
use JSON::PP;

my $method = $ENV{'REQUEST_METHOD'} || '';

my $body = '';

if ($method eq 'POST' || $method eq 'PUT') {
    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;
    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

my $dbh = DB::connect();

my $repository = MateriaRepository->new($dbh);
my $service    = MateriaService->new($repository);

sub validate_materia {
    my ($materia) = @_;

    my @required_fields = qw(
      nombre
      codigo
    );

    foreach my $field (@required_fields) {
        if (!defined $materia->{$field} || $materia->{$field} eq '') {
            return {
                valid => 0,
                error => "El campo '$field' es obligatorio"
            };
        }
    }

    return { valid => 1 };
}

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

# GET MATERIAS / GET MATERIA BY ID
if ($method eq 'GET') {

    my $id = $cgi->param('id');

    if (defined $id) {

        my $materia = $service->get_materia($id);

        if (!$materia) {
            send_error("404 Not Found", "Materia no encontrada");
            exit;
        }

        send_json("200 OK", $materia);
    }
    else {

        my $materias = $service->get_materias();

        send_json("200 OK", $materias);
    }
}

# CREATE MATERIA
elsif ($method eq 'POST') {

    my $materia;

    eval { $materia = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    my $validation = validate_materia($materia);

    unless ($validation->{valid}) {
        send_error("400 Bad Request", $validation->{error});
        exit;
    }

    my $result = $service->create_materia($materia);

    if (!$result->{success}) {

        if ($result->{reason} eq 'codigo_already_exists') {

            send_json("409 Conflict", $result);

            exit;
        }

        if ($result->{reason} eq 'database_error') {

            send_json("500 Internal Server Error", $result);

            exit;
        }
    }

    send_json("201 Created", $result);
}

# UPDATE MATERIA
elsif ($method eq 'PUT') {

    my $id = $cgi->url_param('id');

    unless (defined $id) {

        send_error("400 Bad Request", "El id es obligatorio");

        exit;
    }

    my $materia;

    eval { $materia = decode_json($body); };

    if ($@) {

        send_error("400 Bad Request", "JSON invalido");

        exit;
    }

    my $validation = validate_materia($materia);

    unless ($validation->{valid}) {

        send_error("400 Bad Request", $validation->{error});

        exit;
    }

    my $result = $service->update_materia($id, $materia);

    if (!$result->{success}) {

        if ($result->{reason} eq 'materia_not_found') {

            send_json("404 Not Found", $result);

            exit;
        }

        if ($result->{reason} eq 'codigo_already_exists') {

            send_json("409 Conflict", $result);

            exit;
        }

        if ($result->{reason} eq 'database_error') {

            send_json("500 Internal Server Error", $result);

            exit;
        }
    }

    send_json("200 OK", $result);
}

# DELETE MATERIA
elsif ($method eq 'DELETE') {

    my $id = $cgi->url_param('id');

    unless (defined $id) {

        send_error("400 Bad Request", "El id es obligatorio");

        exit;
    }

    my $result = $service->delete_materia($id);

    if (!$result->{success}) {

        if ($result->{reason} eq 'materia_not_found') {

            send_json("404 Not Found", $result);

            exit;
        }

        if ($result->{reason} eq 'database_error') {

            send_json("500 Internal Server Error", $result);

            exit;
        }
    }

    send_json("200 OK", $result);
}

else {

    send_error("405 Method Not Allowed", "Metodo HTTP no soportado");
}

$dbh->disconnect();
