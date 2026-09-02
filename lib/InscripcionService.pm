package InscripcionService;

use strict;
use warnings;

sub new {
    my ($class, $inscripcion_repository, $student_repository,
        $carrera_repository)
      = @_;

    my $self = {
        inscripcion_repository => $inscripcion_repository,
        student_repository     => $student_repository,
        carrera_repository     => $carrera_repository
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
    my ($self, $estudiante_id, $carrera_id) = @_;

    # 1. Verificar que exista el estudiante

    my $estudiante = $self->{student_repository}->find_by_id($estudiante_id);

    if (!$estudiante) {
        return {
            success => 0,
            reason  => 'student_not_found'
        };
    }

    # 2. Verificar que exista la carrera

    my $carrera = $self->{carrera_repository}->find_by_id($carrera_id);

    if (!$carrera) {
        return {
            success => 0,
            reason  => 'carrera_not_found'
        };
    }

    # 3. Verificar que no exista la inscripción

    my $existing =
      $self->{inscripcion_repository}
      ->find_by_student_and_career($estudiante_id, $carrera_id);

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
          $self->{inscripcion_repository}->create($estudiante_id, $carrera_id);
    };

    if ($@ || !$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    # 5. Obtener la inscripción completa
    #    para devolver el formato con estudiante + carrera

    my $inscripcion =
      $self->{inscripcion_repository}->find_by_id($created->{id});

    return {
        success     => 1,
        inscripcion => $inscripcion
    };
}

sub create_inscripcion_publica {
    my ($self, $student_data, $carrera_id) = @_;

    # 1. Verificar que exista la carrera
    my $carrera = $self->{carrera_repository}->find_by_id($carrera_id);

    if (!$carrera) {
        return {
            success => 0,
            reason  => 'carrera_not_found'
        };
    }

    # 2. Buscar estudiante por DNI
    my $student_by_dni =
      $self->{student_repository}->find_by_dni($student_data->{dni});

    # 3. Buscar estudiante por EMAIL
    my $student_by_email =
      $self->{student_repository}->find_by_email($student_data->{email});

    # 4. Si DNI y EMAIL existen pero pertenecen a estudiantes diferentes
    if (   $student_by_dni
        && $student_by_email
        && $student_by_dni->{id} != $student_by_email->{id})
    {

        return {
            success => 0,
            reason  => 'dni_email_conflict'
        };
    }

    my $estudiante;
    my $estudiante_id;

    # 5. Si existe por DNI
    if ($student_by_dni) {

        $estudiante    = $student_by_dni;
        $estudiante_id = $student_by_dni->{id};

        # Actualizar los datos del estudiante
        my $updated =
          $self->{student_repository}->update($estudiante_id, $student_data);

        if (!$updated) {
            return {
                success => 0,
                reason  => 'database_error'
            };
        }

        $estudiante = $updated;
    }

    # 6. Si no existe por DNI pero existe por EMAIL
    elsif ($student_by_email) {

        $estudiante    = $student_by_email;
        $estudiante_id = $student_by_email->{id};

        # Actualizar los datos del estudiante
        my $updated =
          $self->{student_repository}->update($estudiante_id, $student_data);

        if (!$updated) {
            return {
                success => 0,
                reason  => 'database_error'
            };
        }

        $estudiante = $updated;
    }

    # 7. Si no existe ni por DNI ni por EMAIL, crear estudiante
    else {

        my $created = $self->{student_repository}->create($student_data);

        if (!$created) {
            return {
                success => 0,
                reason  => 'database_error'
            };
        }

        $estudiante    = $created;
        $estudiante_id = $created->{id};
    }

    # 8. Verificar si ya está inscripto en la carrera
    my $existing =
      $self->{inscripcion_repository}
      ->find_by_student_and_career($estudiante_id, $carrera_id);

    if ($existing) {
        return {
            success => 0,
            reason  => 'inscripcion_already_exists'
        };
    }

    # 9. Crear inscripción
    my $created_inscripcion;

    eval {
        $created_inscripcion =
          $self->{inscripcion_repository}->create($estudiante_id, $carrera_id);
    };

    if ($@ || !$created_inscripcion) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    # 10. Obtener inscripción completa
    my $inscripcion =
      $self->{inscripcion_repository}->find_by_id($created_inscripcion->{id});

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
