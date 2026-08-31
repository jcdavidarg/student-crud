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

    my $created = $self->{repository}->create($student);

    return {
        success => 1,
        student => $created
    };
}

1;
