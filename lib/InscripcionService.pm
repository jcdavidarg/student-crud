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

sub _verificar_inscripcion_existente {
    my ($self, $estudiante_id, $carrera_id) = @_;

    # ¿Está inscripto en la MISMA carrera?
    my $misma =
      $self->{inscripcion_repository}->find_by_student_and_career(
        $estudiante_id, $carrera_id);

    if ($misma) {
        return {
            success => 0,
            reason  => 'inscripcion_already_exists',
            carrera => {
                id     => $carrera_id
            }
        };
    }

    # ¿Está inscripto en OTRA carrera?
    my $otra = $self->{inscripcion_repository}->find_by_student($estudiante_id);

    if ($otra) {
        return {
            success => 0,
            reason  => 'inscripcion_en_otra_carrera',
            carrera => {
                id     => $otra->{carrera_id},
                nombre => $otra->{carrera_nombre},
                codigo => $otra->{carrera_codigo}
            }
        };
    }

    return { success => 1 };
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

    my $verificacion =
      $self->_verificar_inscripcion_existente($estudiante_id, $carrera_id);

    if (!$verificacion->{success}) {
        return $verificacion;
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

    # 2. Verificar que el DNI no exista (solo se permiten estudiantes nuevos)
    my $existing_dni =
      $self->{student_repository}->find_by_dni($student_data->{dni});

    if ($existing_dni) {
        return {
            success => 0,
            reason  => 'dni_already_exists'
        };
    }

    # 3. Verificar que el email no exista (solo se permiten estudiantes nuevos)
    my $existing_email =
      $self->{student_repository}->find_by_email($student_data->{email});

    if ($existing_email) {
        return {
            success => 0,
            reason  => 'email_already_exists'
        };
    }

    # 4. Crear el estudiante (solo si DNI y email son nuevos)
    my $created = $self->{student_repository}->create($student_data);

    if (!$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    my $estudiante_id = $created->{id};

    # 5. Verificar que no exista la inscripción (defensa en profundidad)
    my $verificacion =
      $self->_verificar_inscripcion_existente($estudiante_id, $carrera_id);

    if (!$verificacion->{success}) {
        return $verificacion;
    }

    # 6. Crear inscripción
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

    # 7. Obtener inscripción completa
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
