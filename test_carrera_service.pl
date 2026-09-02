#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use DB;
use CarreraRepository;
use CarreraService;
use Data::Dumper;

my $dbh = DB::connect();

my $repository = CarreraRepository->new($dbh);
my $service    = CarreraService->new($repository);

my $carreras = $service->get_carreras();

print Dumper($carreras);

$dbh->disconnect();
