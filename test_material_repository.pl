#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use DB;
use MateriaRepository;

my $dbh = DB::connect();

print "Conexión exitosa a PostgreSQL\n";


my $repo = MateriaRepository->new($dbh);

my $materias = $repo->find_all();

foreach my $materia (@$materias) {
    print "$materia->{id} - $materia->{codigo} - $materia->{nombre}\n";
}

$dbh->disconnect();
