package CarreraService;

use strict;
use warnings;

sub new {
    my ($class, $repository) = @_;

    my $self = { repository => $repository };

    return bless $self, $class;
}

sub get_carreras {
    my ($self) = @_;

    return $self->{repository}->find_all();
}

sub get_carrera {
    my ($self, $id) = @_;

    return $self->{repository}->find_by_id($id);
}

sub create_carrera {
    my ($self, $carrera) = @_;

    my $existing_carrera =
      $self->{repository}->find_by_codigo($carrera->{codigo});

    if ($existing_carrera) {
        return {
            success => 0,
            reason  => 'codigo_already_exists',
            carrera => $existing_carrera
        };
    }

    my $created;

    eval { $created = $self->{repository}->create($carrera); };

    if ($@ || !$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        carrera => $created
    };
}

sub update_carrera {
    my ($self, $id, $carrera) = @_;

    my $existing_carrera = $self->{repository}->find_by_id($id);

    if (!$existing_carrera) {
        return {
            success => 0,
            reason  => 'carrera_not_found'
        };
    }

    if ($carrera->{codigo} ne $existing_carrera->{codigo}) {

        my $carrera_with_codigo =
          $self->{repository}->find_by_codigo($carrera->{codigo});

        if ($carrera_with_codigo) {
            return {
                success => 0,
                reason  => 'codigo_already_exists',
                carrera => $carrera_with_codigo
            };
        }
    }

    my $updated;

    eval { $updated = $self->{repository}->update($id, $carrera); };

    if ($@ || !$updated) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        carrera => $updated
    };
}

sub delete_carrera {
    my ($self, $id) = @_;

    my $existing_carrera = $self->{repository}->find_by_id($id);

    if (!$existing_carrera) {
        return {
            success => 0,
            reason  => 'carrera_not_found'
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
        carrera => $existing_carrera
    };
}

1;
