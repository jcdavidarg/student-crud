#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use DB;
use StudentRepository;

my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);

my $students = $repository->find_all();

foreach my $student (@$students) {
    print "ID: $student->{id}\n";
    print "Nombre: $student->{nombre}\n";
    print "Apellido: $student->{apellido}\n";
    print "DNI: $student->{dni}\n";
    print "Email: $student->{email}\n";
    print "Nacionalidad: $student->{nacionalidad}\n";
    print "----------------------\n";
}

$dbh->disconnect();
