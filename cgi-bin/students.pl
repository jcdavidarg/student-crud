#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use DB;
use StudentRepository;
use StudentService;
use JSON::PP;
use CGI;

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
