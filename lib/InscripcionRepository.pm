package InscripcionRepository;

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
            i.id,
            i.estudiante_id,
            e.nombre AS estudiante_nombre,
            e.apellido AS estudiante_apellido,
            i.materia_id,
            m.nombre AS materia_nombre,
            m.codigo AS materia_codigo,
            i.fecha_inscripcion
        FROM inscripciones i
        JOIN estudiantes e
            ON e.id = i.estudiante_id
        JOIN materias m
            ON m.id = i.materia_id
        ORDER BY i.id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute();

    my @inscripciones;

    while (my $row = $sth->fetchrow_hashref()) {
        push @inscripciones, _format_inscripcion($row);
    }

    return \@inscripciones;
}

sub find_by_id {
    my ($self, $id) = @_;

    my $sql = '
        SELECT
            i.id,
            i.estudiante_id,
            e.nombre AS estudiante_nombre,
            e.apellido AS estudiante_apellido,
            i.materia_id,
            m.nombre AS materia_nombre,
            m.codigo AS materia_codigo,
            i.fecha_inscripcion
        FROM inscripciones i
        JOIN estudiantes e
            ON e.id = i.estudiante_id
        JOIN materias m
            ON m.id = i.materia_id
        WHERE i.id = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    my $row = $sth->fetchrow_hashref();

    return $row ? _format_inscripcion($row) : undef;
}

sub find_by_student_and_subject {
    my ($self, $estudiante_id, $materia_id) = @_;

    my $sql = '
        SELECT
            id,
            estudiante_id,
            materia_id,
            fecha_inscripcion
        FROM inscripciones
        WHERE estudiante_id = ?
          AND materia_id = ?
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($estudiante_id, $materia_id);

    return $sth->fetchrow_hashref();
}

sub create {
    my ($self, $estudiante_id, $materia_id) = @_;

    my $sql = '
        INSERT INTO inscripciones (
            estudiante_id,
            materia_id
        )
        VALUES (?, ?)
        RETURNING
            id,
            estudiante_id,
            materia_id,
            fecha_inscripcion
    ';

    my $sth = $self->{dbh}->prepare($sql);

    my $success = eval {
        $sth->execute($estudiante_id, $materia_id);

        1;
    };

    if (!$success) {
        return undef;
    }

    return $sth->fetchrow_hashref();
}

sub delete {
    my ($self, $id) = @_;

    my $sql = '
        DELETE FROM inscripciones
        WHERE id = ?
        RETURNING id
    ';

    my $sth = $self->{dbh}->prepare($sql);

    $sth->execute($id);

    return $sth->fetchrow_hashref();
}

sub _format_inscripcion {
    my ($row) = @_;

    return {
        id => $row->{id},

        estudiante => {
            id       => $row->{estudiante_id},
            nombre   => $row->{estudiante_nombre},
            apellido => $row->{estudiante_apellido}
        },

        materia => {
            id     => $row->{materia_id},
            nombre => $row->{materia_nombre},
            codigo => $row->{materia_codigo}
        },

        fecha_inscripcion => $row->{fecha_inscripcion}
    };
}

1;
