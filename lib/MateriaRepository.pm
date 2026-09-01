package MateriaRepository;

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
            codigo
        FROM materias
        ORDER BY id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute();

    my @materias;

    while (my $materia = $sth->fetchrow_hashref()) {
        push @materias, $materia;
    }

    return \@materias;
}

sub find_by_id {
    my ($self, $id) = @_;

    my $sql = '
        SELECT
            id,
            nombre,
            codigo
        FROM materias
        WHERE id = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

sub find_by_codigo {
    my ($self, $codigo) = @_;

    my $sql = '
        SELECT
            id,
            nombre,
            codigo
        FROM materias
        WHERE codigo = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($codigo);

    return $sth->fetchrow_hashref();
}

sub create {
    my ($self, $materia) = @_;

    my $sql = '
        INSERT INTO materias (
            nombre,
            codigo
        )
        VALUES (?, ?)
        RETURNING
            id,
            nombre,
            codigo
    ';

    my $sth = $self->{dbh}->prepare($sql);

    my $success = eval {
        $sth->execute($materia->{nombre}, $materia->{codigo});

        1;
    };

    if (!$success) {
        return undef;
    }

    return $sth->fetchrow_hashref();
}

sub update {
    my ($self, $id, $materia) = @_;

    my $sql = '
        UPDATE materias
        SET
            nombre = ?,
            codigo = ?
        WHERE id = ?
        RETURNING
            id,
            nombre,
            codigo
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($materia->{nombre}, $materia->{codigo}, $id);

    return $sth->fetchrow_hashref();
}

sub delete {
    my ($self, $id) = @_;

    my $sql = '
        DELETE FROM materias
        WHERE id = ?
        RETURNING id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

1;
