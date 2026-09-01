package MateriaService;

use strict;
use warnings;

sub new {
    my ($class, $repository) = @_;

    my $self = { repository => $repository };

    return bless $self, $class;
}

sub get_materias {
    my ($self) = @_;

    return $self->{repository}->find_all();
}

sub get_materia {
    my ($self, $id) = @_;

    return $self->{repository}->find_by_id($id);
}

sub create_materia {
    my ($self, $materia) = @_;

    my $existing_materia =
      $self->{repository}->find_by_codigo($materia->{codigo});

    if ($existing_materia) {
        return {
            success => 0,
            reason  => 'codigo_already_exists',
            materia => $existing_materia
        };
    }

    my $created;

    eval { $created = $self->{repository}->create($materia); };

    if ($@ || !$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        materia => $created
    };
}

sub update_materia {
    my ($self, $id, $materia) = @_;

    my $existing_materia = $self->{repository}->find_by_id($id);

    if (!$existing_materia) {
        return {
            success => 0,
            reason  => 'materia_not_found'
        };
    }

    if ($materia->{codigo} ne $existing_materia->{codigo}) {

        my $materia_with_codigo =
          $self->{repository}->find_by_codigo($materia->{codigo});

        if ($materia_with_codigo) {
            return {
                success => 0,
                reason  => 'codigo_already_exists',
                materia => $materia_with_codigo
            };
        }
    }

    my $updated;

    eval { $updated = $self->{repository}->update($id, $materia); };

    if ($@ || !$updated) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        materia => $updated
    };
}

sub delete_materia {
    my ($self, $id) = @_;

    my $existing_materia = $self->{repository}->find_by_id($id);

    if (!$existing_materia) {
        return {
            success => 0,
            reason  => 'materia_not_found'
        };
    }

    my $deleted;

    eval { $deleted = $self->{repository}->delete($id); };

    if ($@ || !$deleted) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        materia => $existing_materia
    };
}

1;
