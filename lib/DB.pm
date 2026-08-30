package DB;

use strict;
use warnings;
use DBI;

sub connect {
    my $dbh = DBI->connect(
        "dbi:Pg:dbname=students_db;host=localhost",
        "postgres",
        "TU_PASSWORD",
        {
            RaiseError => 1,
            AutoCommit => 1
        }
    );

    return $dbh;
}

1;
