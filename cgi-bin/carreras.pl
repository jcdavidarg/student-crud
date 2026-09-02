#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CGI;
use DB;
use CarreraRepository;
use CarreraService;
use JSON::PP;

my $method = $ENV{'REQUEST_METHOD'} || '';

my $body = '';

if ($method eq 'POST' || $method eq 'PUT') {
    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;
    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

my $dbh = DB::connect();

my $repository = CarreraRepository->new($dbh);
my $service    = CarreraService->new($repository);

sub validate_carrera {
    my ($carrera) = @_;

    my @required_fields = qw(
      nombre
      codigo
    );

    foreach my $field (@required_fields) {
        if (!defined $carrera->{$field} || $carrera->{$field} eq '') {
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

# GET CARRERAS / GET CARRERA BY ID
if ($method eq 'GET') {

    my $id = $cgi->param('id');

    if (defined $id) {

        my $carrera = $service->get_carrera($id);

        if (!$carrera) {
            send_error("404 Not Found", "Carrera no encontrada");
            exit;
        }

        send_json("200 OK", $carrera);
    }
    else {

        my $carreras = $service->get_carreras();

        send_json("200 OK", $carreras);
    }
}

# CREATE CARRERA
elsif ($method eq 'POST') {

    my $carrera;

    eval { $carrera = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    my $validation = validate_carrera($carrera);

    unless ($validation->{valid}) {
        send_error("400 Bad Request", $validation->{error});
        exit;
    }

    my $result = $service->create_carrera($carrera);

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

# UPDATE CARRERA
elsif ($method eq 'PUT') {

    my $id = $cgi->param('id');

    unless (defined $id) {

        send_error("400 Bad Request", "El id es obligatorio");

        exit;
    }

    my $carrera;

    eval { $carrera = decode_json($body); };

    if ($@) {

        send_error("400 Bad Request", "JSON invalido");

        exit;
    }

    my $validation = validate_carrera($carrera);

    unless ($validation->{valid}) {

        send_error("400 Bad Request", $validation->{error});

        exit;
    }

    my $result = $service->update_carrera($id, $carrera);

    if (!$result->{success}) {

        if ($result->{reason} eq 'carrera_not_found') {

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

# DELETE CARRERA
elsif ($method eq 'DELETE') {

    my $id = $cgi->param('id');

    unless (defined $id) {

        send_error("400 Bad Request", "El id es obligatorio");

        exit;
    }

    my $result = $service->delete_carrera($id);

    if (!$result->{success}) {

        if ($result->{reason} eq 'carrera_not_found') {

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
