#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use DB;
use StudentRepository;
use CarreraRepository;
use InscripcionRepository;
use InscripcionService;
use Data::Dumper;

my $dbh = DB::connect();

my $student_repository = StudentRepository->new($dbh);

my $carrera_repository = CarreraRepository->new($dbh);

my $inscripcion_repository = InscripcionRepository->new($dbh);

my $service =
  InscripcionService->new($inscripcion_repository, $student_repository,
    $carrera_repository);


print "\n=== GET INSCRIPCIONES ===\n";

my $inscripciones = $service->get_inscripciones();

print Dumper($inscripciones);


print "\n=== GET INSCRIPCION BY ID ===\n";

my $inscripcion = $service->get_inscripcion(1);

print Dumper($inscripcion);


print "\n=== GET INSCRIPCION INEXISTENTE ===\n";

my $not_found = $service->get_inscripcion(999);

print Dumper($not_found);


print "\n=== CREATE INSCRIPCION DUPLICADA ===\n";

my $duplicate = $service->create_inscripcion(1, 1);

print Dumper($duplicate);


print "\n=== CREATE CON ESTUDIANTE INEXISTENTE ===\n";

my $student_not_found = $service->create_inscripcion(999, 1);

print Dumper($student_not_found);


print "\n=== CREATE CON CARRERA INEXISTENTE ===\n";

my $carrera_not_found = $service->create_inscripcion(1, 999);

print Dumper($carrera_not_found);


print "\n=== CREATE INSCRIPCION VALIDA ===\n";

my $created = $service->create_inscripcion(1, 3);

print Dumper($created);


print "\n=== DELETE INSCRIPCION ===\n";

my $deleted =
  $service->delete_inscripcion($created->{inscripcion}->{id});

print Dumper($deleted);


print "\n=== DELETE INSCRIPCION INEXISTENTE ===\n";

my $delete_not_found = $service->delete_inscripcion(999);

print Dumper($delete_not_found);


$dbh->disconnect();
