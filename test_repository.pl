#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use DB;
use StudentRepository;
use StudentService;

my $dbh = DB::connect();

my $repository = StudentRepository->new($dbh);

my $service = StudentService->new($repository);

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

# testeando Studentservice

=pod
my $student = {
    nombre       => 'Vero',
    apellido     => 'Lloren',
    dni          => '1258656721',
    email        => 'veritooo@email.com',
    nacionalidad => 'Argentina',
    telefono     => '342562'
};

my $result = $service->create_student($student);

if ($result->{success}) {
    print "Estudiante creado correctamente\n";
    print "ID: $result->{student}->{id}\n";
}
else {
    print "El estudiante ya existe\n";
    print "ID existente: $result->{student}->{id}\n";
}
=cut

# testeando update

=pod
my $student = {
    nombre       => 'Juan Carlos',
    apellido     => 'Gomez',
    dni          => '87654321',
    email        => 'juan@test.com',
    nacionalidad => 'Argentina',
    telefono     => '1188888888'
};

my $updated = $repository->update(2, $student);

if ($updated) {
    print "Estudiante actualizado\n";
    print "ID: $updated->{id}\n";
    print "Nombre: $updated->{nombre}\n";
    print "Apellido: $updated->{apellido}\n";
    print "DNI: $updated->{dni}\n";
    print "Email: $updated->{email}\n";
    print "Teléfono: $updated->{telefono}\n";
}
else {
    print "Estudiante no encontrado\n";
}
=cut

# testeando delete user

=pod
my $deleted = $repository->delete(4);

if ($deleted) {
    print "Estudiante eliminado\n";
    print "ID eliminado: $deleted->{id}\n";
}
else {
    print "Estudiante no encontrado\n";
}
=cut

# servide update testeando

=pod
my $student = {
    nombre       => 'Alejandra',
    apellido     => 'DeGennaro',
    dni          => '1258658',
    email        => 'vero33@test.com',
    nacionalidad => 'Argentina',
    telefono     => '1188888'
};

my $result = $service->update_student(6, $student);

if ($result->{success}) {
    print "Estudiante actualizado correctamente\n";
    print "ID: $result->{student}->{id}\n";
    print "Nombre: $result->{student}->{nombre}\n";
    print "Apellido: $result->{student}->{apellido}\n";
    print "DNI: $result->{student}->{dni}\n";
    print "Email: $result->{student}->{email}\n";
    print "Teléfono: $result->{student}->{telefono}\n";
}
else {
    print "El estudiante ya existe\n";
    print "ID existente: $result->{student}->{id}\n";
}
=cut

# servide delete testeando

=pod
my $result = $service->delete_student(2);

if ($result->{success}) {
    print "Estudiante eliminado\n";
    print "ID eliminado: $result->{student}->{id}\n";
}
else {
    print "Estudiante no encontrado\n";
}
=cut

$dbh->disconnect();
