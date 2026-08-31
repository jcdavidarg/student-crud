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

if ($method eq 'POST') {
    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;

    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);
my $service    = StudentService->new($repository);

if ($method eq 'GET') {

    my $id = $cgi->param('id');

    if (defined $id) {

        my $student = $service->get_student($id);

        print "Content-Type: application/json\n\n";

        print encode_json($student);

    }
    else {

        my $students = $service->get_students();

        print "Content-Type: application/json\n\n";

        print encode_json($students);
    }

}
elsif ($method eq 'POST') {

    my $student = decode_json($body);

    my $created = $service->create_student($student);

    print "Content-Type: application/json\n\n";

    print encode_json($created);
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
