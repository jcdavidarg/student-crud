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

sub find_by_id {
    my ($self, $id) = @_;

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
        WHERE id = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

sub find_by_email {
    my ($self, $email) = @_;

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
        WHERE email = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($email);

    return $sth->fetchrow_hashref();
}

sub find_by_email_except_id {
    my ($self, $email, $id) = @_;

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
        WHERE email = ?
          AND id <> ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($email, $id);

    return $sth->fetchrow_hashref();
}

sub create {
    my ($self, $student) = @_;

    my $sql = '
        INSERT INTO estudiantes (
            nombre,
            apellido,
            dni,
            email,
            nacionalidad,
            telefono
        )
        VALUES (?, ?, ?, ?, ?, ?)
        RETURNING
            id,
            nombre,
            apellido,
            dni,
            email,
            nacionalidad,
            telefono
    ';

    my $sth = $self->{dbh}->prepare($sql);

    my $success = eval {
        $sth->execute(
            $student->{nombre},       $student->{apellido},
            $student->{dni},          $student->{email},
            $student->{nacionalidad}, $student->{telefono}
        );

        1;
    };

    if (!$success) {
        return undef;
    }

    return $sth->fetchrow_hashref();
}

sub find_by_dni {
    my ($self, $dni) = @_;

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
        WHERE dni = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($dni);

    return $sth->fetchrow_hashref();
}

sub update {
    my ($self, $id, $student) = @_;

    my $sql = '
        UPDATE estudiantes
        SET
            nombre = ?,
            apellido = ?,
            dni = ?,
            email = ?,
            nacionalidad = ?,
            telefono = ?,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
        RETURNING
            id,
            nombre,
            apellido,
            dni,
            email,
            nacionalidad,
            telefono
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($student->{nombre}, $student->{apellido}, $student->{dni},
        $student->{email},    $student->{nacionalidad},
        $student->{telefono}, $id);

    return $sth->fetchrow_hashref();
}

sub delete {
    my ($self, $id) = @_;

    my $sql = '
        DELETE FROM estudiantes
        WHERE id = ?
        RETURNING id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

1;
