package InscripcionService;

use strict;
use warnings;

sub new {
    my ($class, $inscripcion_repository, $student_repository,
        $materia_repository)
      = @_;

    my $self = {
        inscripcion_repository => $inscripcion_repository,
        student_repository     => $student_repository,
        materia_repository     => $materia_repository
    };

    return bless $self, $class;
}

sub get_inscripciones {
    my ($self) = @_;

    return $self->{inscripcion_repository}->find_all();
}

sub get_inscripcion {
    my ($self, $id) = @_;

    return $self->{inscripcion_repository}->find_by_id($id);
}

sub create_inscripcion {
    my ($self, $estudiante_id, $materia_id) = @_;

    # 1. Verificar que exista el estudiante

    my $estudiante = $self->{student_repository}->find_by_id($estudiante_id);

    if (!$estudiante) {
        return {
            success => 0,
            reason  => 'student_not_found'
        };
    }

    # 2. Verificar que exista la materia

    my $materia = $self->{materia_repository}->find_by_id($materia_id);

    if (!$materia) {
        return {
            success => 0,
            reason  => 'materia_not_found'
        };
    }

    # 3. Verificar que no exista la inscripción

    my $existing =
      $self->{inscripcion_repository}
      ->find_by_student_and_subject($estudiante_id, $materia_id);

    if ($existing) {
        return {
            success => 0,
            reason  => 'inscripcion_already_exists'
        };
    }

    # 4. Crear inscripción

    my $created;

    eval {
        $created =
          $self->{inscripcion_repository}->create($estudiante_id, $materia_id);
    };

    if ($@ || !$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    # 5. Obtener la inscripción completa
    #    para devolver el formato con estudiante + materia

    my $inscripcion =
      $self->{inscripcion_repository}->find_by_id($created->{id});

    return {
        success     => 1,
        inscripcion => $inscripcion
    };
}

sub delete_inscripcion {
    my ($self, $id) = @_;

    # 1. Verificar que exista

    my $existing = $self->{inscripcion_repository}->find_by_id($id);

    if (!$existing) {
        return {
            success => 0,
            reason  => 'inscripcion_not_found'
        };
    }

    # 2. Eliminar

    my $deleted;

    eval { $deleted = $self->{inscripcion_repository}->delete($id); };

    if ($@ || !$deleted) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success     => 1,
        inscripcion => $existing
    };
}

1;
