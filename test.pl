#!/usr/bin/perl

# uso obligatorio
use strict;
use warnings;

# print "Hola desde Perl\n";

# -----------------------------
# variable simple

=pod
my $name = "David";

print "Hola $name\n";
=cut

# -----------------------------
# tipos de variables

=pod
$variable    → scalar
@variables   → array
%variables   → hash
=cut

# -----------------------------
# arrays

=pod
my @estudiantes = ("Juan", "Pedro", "David");

foreach my $estudiante (@estudiantes) {
    print "$estudiante\n";
}
=cut

# -----------------------------
# hash puro

=pod
my %estudiante = (
    nombre => "David",
    edad   => 36,
    email  => 'david@arg.com'
);

print "$estudiante{nombre}\n";
=cut

# hash por referencia
# se construye con $ y {}

=pod
my $estudiante = {
    nombre => "David",
    edad   => 36,
    email  => 'david@arg.com'
};


# se usa las flechas por referencia
print "$estudiante->{nombre}\n";
=cut


my $estudiante = {
    nombre => "David",
    edad   => 36,
    email  => 'david@test.com'
};

print "Nombre: $estudiante->{nombre}\n";
print "Edad: $estudiante->{edad}\n";
print "Email: $estudiante->{email}\n";
