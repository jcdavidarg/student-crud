#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use Student;

my $student =
  Student->new("David", "Jaimez", 33442123, 'jcdavid@gmail.com', "Argentina",
    1122334455);

print "Nombre: " . $student->nombre . "\n";
print "Apellido: " . $student->apellido . "\n";
print "DNI: " . $student->dni . "\n";
print "Email: " . $student->email . "\n";
print "Nacionalidad: " . $student->nacionalidad . "\n";
print "Telefono: " . $student->telefono . "\n";


print Student::global();
print Student::global();
print Student::global();
print Student::global();
print Student::global();
print Student::global();
