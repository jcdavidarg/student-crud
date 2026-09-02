#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use DB;
use InscripcionRepository;
use Data::Dumper;

my $dbh = DB::connect();

my $repository = InscripcionRepository->new($dbh);

# print "\n=== FIND ALL ===\n";

# my $inscripciones = $repository->find_all();

# print Dumper($inscripciones);


# print "\n=== FIND BY ID ===\n";

# my $inscripcion = $repository->find_by_id(1);

# print Dumper($inscripcion);


# print "\n=== FIND BY ID INEXISTENTE ===\n";

# my $not_found = $repository->find_by_id(9999);

# print Dumper($not_found);


# print "\n=== FIND BY STUDENT AND SUBJECT ===\n";

# my $existing = $repository->find_by_student_and_career(1, 1);

# print Dumper($existing);


# print "\n=== STUDENT AND SUBJECT INEXISTENTE ===\n";

# my $not_existing = $repository->find_by_student_and_career(1, 2);

# print Dumper($not_existing);

print "\n=== CREATE INSCRIPCION ===\n";

my $created = $repository->create(3, 2);

print Dumper($created);

# print "\n=== DELETE INSCRIPCION ===\n";

# my $deleted = $repository->delete(2);

# print Dumper($deleted);


# print "\n=== FIND BY ID AFTER DELETE ===\n";

# my $after_delete = $repository->find_by_id(2);

# print Dumper($after_delete);


$dbh->disconnect();
