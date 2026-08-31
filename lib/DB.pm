package DB;

use strict;
use warnings;
use DBI;

sub connect {
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=students_db;host=localhost",
        "students_user",
        "students123",
        {
            RaiseError => 1,
            AutoCommit => 1
        }
    );

    return $dbh;
}

1;
