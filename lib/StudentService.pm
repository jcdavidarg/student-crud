package StudentService;

use strict;
use warnings;

sub new {
    my ($class, $repository) = @_;

    my $self = { repository => $repository };

    return bless $self, $class;
}

sub create_student {
    my ($self, $student) = @_;

    my $existing_student =
      $self->{repository}->find_by_dni($student->{dni});

    if ($existing_student) {
        return {
            success => 0,
            reason  => 'student_exists',
            student => $existing_student
        };
    }

    my $existing_email =
      $self->{repository}->find_by_email($student->{email});

    if ($existing_email) {
        return {
            success => 0,
            reason  => 'email_already_exists',
            student => $existing_email
        };
    }

    my $created = $self->{repository}->create($student);

    if (!$created) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        student => $created
    };
}


sub update_student {
    my ($self, $id, $student) = @_;

    my $existing_student = $self->{repository}->find_by_id($id);

    if (!$existing_student) {
        return {
            success => 0,
            reason  => 'student_not_found'
        };
    }

    if ($student->{dni} ne $existing_student->{dni}) {

        my $student_with_dni =
          $self->{repository}->find_by_dni($student->{dni});

        if ($student_with_dni) {
            return {
                success => 0,
                reason  => 'dni_already_exists',
                student => $student_with_dni
            };
        }
    }

    if ($student->{email} ne $existing_student->{email}) {

        my $student_with_email =
          $self->{repository}->find_by_email_except_id($student->{email}, $id);

        if ($student_with_email) {
            return {
                success => 0,
                reason  => 'email_already_exists',
                student => $student_with_email
            };
        }
    }

    my $updated = $self->{repository}->update($id, $student);

    if (!$updated) {
        return {
            success => 0,
            reason  => 'database_error'
        };
    }

    return {
        success => 1,
        student => $updated
    };
}

sub delete_student {
    my ($self, $id) = @_;

    my $existing_student = $self->{repository}->find_by_id($id);

    if (!$existing_student) {
        return {
            success => 0,
            reason  => 'student_not_found'
        };
    }

    my $deleted = $self->{repository}->delete($id);

    return {
        success => 1,
        student => $existing_student
    };
}

sub get_students {
    my ($self) = @_;

    return $self->{repository}->find_all();
}

sub get_student {
    my ($self, $id) = @_;

    return $self->{repository}->find_by_id($id);
}
1;
