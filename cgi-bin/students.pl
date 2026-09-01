#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CGI;
use DB;
use StudentRepository;
use StudentService;
use JSON::PP;

my $method = $ENV{'REQUEST_METHOD'} || '';

my $body = '';

if ($method eq 'POST' || $method eq 'PUT') {
    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;

    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);
my $service    = StudentService->new($repository);

sub validate_student {
    my ($student) = @_;

    my @required_fields = qw(
      nombre
      apellido
      dni
      email
    );

    foreach my $field (@required_fields) {

        if (!defined $student->{$field} || $student->{$field} eq '') {
            return {
                valid => 0,
                error => "El campo '$field' es obligatorio"
            };
        }
    }

    if ($student->{dni} !~ /^\d{8}$/) {
        return {
            valid => 0,
            error => "El DNI debe contener 8 digitos"
        };
    }

    if ($student->{email} !~ /^[^@\s]+@[^@\s]+\.[^@\s]+$/) {
        return {
            valid => 0,
            error => "El email no es valido"
        };
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

# GET STUDENTS AND STUDENT BY ID
if ($method eq 'GET') {

    my $id = $cgi->param('id');

    if (defined $id) {

        my $student = $service->get_student($id);

        if (!$student) {
            send_error("404 Not Found", "Estudiante no encontrado");
            exit;
        }

        send_json("200 OK", $student);
    }
    else {

        my $students = $service->get_students();

        print "Content-Type: application/json\n\n";

        print encode_json($students);
    }

}    # CREATE STUDENT
elsif ($method eq 'POST') {

    my $student;

    eval { $student = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    my $validation = validate_student($student);

    unless ($validation->{valid}) {
        send_error("400 Bad Request", $validation->{error});
        exit;
    }

    my $result = $service->create_student($student);

    if (!$result->{success}) {

        if ($result->{reason} eq 'student_exists') {

            send_json("409 Conflict", $result);
            exit;
        }

        elsif ($result->{reason} eq 'email_already_exists') {

            send_json("409 Conflict", $result);
            exit;
        }

        elsif ($result->{reason} eq 'database_error') {

            send_json("500 Internal Server Error", $result);
            exit;
        }
    }

    send_json("201 Created", $result);
}    # UPDATE STUDENT
elsif ($method eq 'PUT') {

    my $id = $cgi->url_param('id');

    unless (defined $id) {
        send_error("400 Bad Request", "El id es obligatorio");
        exit;
    }

    my $student;

    eval { $student = decode_json($body); };

    if ($@) {
        send_error("400 Bad Request", "JSON invalido");
        exit;
    }

    my $validation = validate_student($student);

    unless ($validation->{valid}) {
        send_error("400 Bad Request", $validation->{error});
        exit;
    }

    my $result = $service->update_student($id, $student);


    if (!$result->{success}) {

        if ($result->{reason} eq 'student_not_found') {

            send_json("404 Not Found", $result);
        }
        elsif ($result->{reason} eq 'dni_already_exists') {

            send_json("409 Conflict", $result);
        }
        elsif ($result->{reason} eq 'email_already_exists') {

            send_json("409 Conflict", $result);
        }
        elsif ($result->{reason} eq 'database_error') {

            send_json("500 Internal Server Error", $result);
        }

        exit;
    }

    send_json("200 OK", $result);
}    # DELETE STUDENT
elsif ($method eq 'DELETE') {

    my $id = $cgi->url_param('id');

    unless (defined $id) {
        send_error("400 Bad Request", "El id es obligatorio");
        exit;
    }

    my $result = $service->delete_student($id);

    if (!$result->{success}) {

        if ($result->{reason} eq 'student_not_found') {
            send_json("404 Not Found", $result);
            exit;
        }
    }

    send_json("200 OK", $result);
}
else {

    print "Content-Type: application/json\n\n";

    print encode_json(
        {
            error => "Metodo HTTP no soportado"
        }
    );
}

$dbh->disconnect();

=pod
my $students = [
    {
        id       => 1,
        nombre   => 'David',
        apellido => 'Perez'
    },
    {
        id       => 2,
        nombre   => 'Juan',
        apellido => 'Gomez'
    }
];
=cut

=pod
my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);
my $service    = StudentService->new($repository);

my $students = $service->get_students();

print "Content-Type: application/json\n\n";

print encode_json($students);

$dbh->disconnect();
=cut

=pod
my $cgi = CGI->new;

my $method = $cgi->request_method;

print "Content-Type: text/plain\n\n";
print "Metodo HTTP: $method\n";
=cut
