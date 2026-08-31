#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use DB;

my $dbh = DB::connect();

print "Conexión exitosa a PostgreSQL\n";

my $sql =
  'SELECT id, nombre, apellido, dni, email, nacionalidad FROM estudiantes';

my $sth = $dbh->prepare($sql);

$sth->execute();

while (my $student = $sth->fetchrow_hashref()) {
    print "ID: $student->{id}\n";
    print "Nombre: $student->{nombre}\n";
    print "Apellido: $student->{apellido}\n";
    print "DNI: $student->{dni}\n";
    print "Email: $student->{email}\n";
    print "Nacionalidad: $student->{nacionalidad}\n";
    print "----------------------\n";
}

$dbh->disconnect();
