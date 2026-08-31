package StudentRepository;

use strict;
use warnings;

sub new {
    my ($class, $dbh) = @_;

    my $self = { dbh => $dbh };

    return bless $self, $class;
}

sub find_all {
    my ($self) = @_;

    my $sql = '
        SELECT
            id,
            nombre,
            apellido,
            dni,
            email,
            nacionalidad,
            telefono
        FROM estudiantes
        ORDER BY id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute();

    my @students;

    while (my $student = $sth->fetchrow_hashref()) {
        push @students, $student;
    }

    return \@students;
}


1;
