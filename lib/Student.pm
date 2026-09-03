package Student;

use strict;
use warnings;

sub new {

    my ($class, $nombre, $apellido, $dni, $email, $nacionalidad, $telefono) =
      @_;

    my $self = {
        nombre       => $nombre,
        apellido     => $apellido,
        dni          => $dni,
        email        => $email,
        nacionalidad => $nacionalidad,
        telefono     => $telefono
    };

    return bless $self, $class;
}

sub nombre {
    my ($self) = @_;

    return $self->{nombre};
}

sub apellido {
    my ($self) = @_;

    return $self->{apellido};
}

sub dni {
    my ($self) = @_;

    return $self->{dni};
}

sub email {
    my ($self) = @_;

    return $self->{email};
}

sub nacionalidad {
    my ($self) = @_;

    return $self->{nacionalidad};
}

sub telefono {
    my ($self) = @_;

    return $self->{telefono};
}

1;
