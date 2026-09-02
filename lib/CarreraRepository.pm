package CarreraRepository;

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
        FROM carreras
        ORDER BY id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute();

    my @carreras;

    while (my $carrera = $sth->fetchrow_hashref()) {
        push @carreras, $carrera;
    }

    return \@carreras;
}

sub find_by_id {
    my ($self, $id) = @_;

    my $sql = '
        SELECT
            id,
            nombre,
            codigo
        FROM carreras
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
        FROM carreras
        WHERE codigo = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($codigo);

    return $sth->fetchrow_hashref();
}

sub create {
    my ($self, $carrera) = @_;

    my $sql = '
        INSERT INTO carreras (
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
        $sth->execute($carrera->{nombre}, $carrera->{codigo});

        1;
    };

    if (!$success) {
        return undef;
    }

    return $sth->fetchrow_hashref();
}

sub update {
    my ($self, $id, $carrera) = @_;

    my $sql = '
        UPDATE carreras
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

    $sth->execute($carrera->{nombre}, $carrera->{codigo}, $id);

    return $sth->fetchrow_hashref();
}

sub delete {
    my ($self, $id) = @_;

    my $sql = '
        DELETE FROM carreras
        WHERE id = ?
        RETURNING id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

1;
