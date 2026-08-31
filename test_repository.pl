#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use DB;
use StudentRepository;

my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);

#test find_all

=pod
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
=cut

#test find_by_id

=pod
my $student = $repository->find_by_id(1);

if ($student) {
    print "Estudiante encontrado\n";
    print "ID: $student->{id}\n";
    print "Nombre: $student->{nombre}\n";
    print "Apellido: $student->{apellido}\n";
    print "DNI: $student->{dni}\n";
    print "Email: $student->{email}\n";
    print "Nacionalidad: $student->{nacionalidad}\n";
    print "Teléfono: $student->{telefono}\n";
}
else {
    print "Estudiante no encontrado\n";
}
=cut

# test create

=pod
my $student = {
    nombre       => 'Juan',
    apellido     => 'Gomez',
    dni          => '87654321',
    email        => 'juan@test.com',
    nacionalidad => 'Argentina',
    telefono     => '1199999999'
};

my $created = $repository->create($student);

print "Estudiante creado\n";
print "ID: $created->{id}\n";
print "Nombre: $created->{nombre}\n";
print "Apellido: $created->{apellido}\n";
print "DNI: $created->{dni}\n";
print "Email: $created->{email}\n";
=cut

# test find_by_dni

=pod
my $student = $repository->find_by_dni('87654321');

if ($student) {
    print "Estudiante encontrado\n";
    print "ID: $student->{id}\n";
    print "Nombre: $student->{nombre}\n";
    print "Apellido: $student->{apellido}\n";
    print "DNI: $student->{dni}\n";
    print "Email: $student->{email}\n";
}
else {
    print "Estudiante no encontrado\n";
}
=cut

$dbh->disconnect();
