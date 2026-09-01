#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use DB;
use MateriaRepository;
use MateriaService;
use Data::Dumper;

my $dbh = DB::connect();

my $repository = MateriaRepository->new($dbh);
my $service    = MateriaService->new($repository);

my $materias = $service->get_materias();

print Dumper($materias);

$dbh->disconnect();
