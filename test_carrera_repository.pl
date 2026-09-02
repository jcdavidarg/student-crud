#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use DB;
use CarreraRepository;

my $dbh = DB::connect();

print "Conexión exitosa a PostgreSQL\n";


my $repo = CarreraRepository->new($dbh);

my $carreras = $repo->find_all();

foreach my $carrera (@$carreras) {
    print "$carrera->{id} - $carrera->{codigo} - $carrera->{nombre}\n";
}

$dbh->disconnect();
