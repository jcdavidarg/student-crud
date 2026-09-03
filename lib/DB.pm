package DB;

use strict;
use warnings;

use DBI;

# Asegurar que lib/ este en @INC para cargar App::Config.pm
use File::Spec;
use lib File::Spec->catdir(
    (File::Spec->splitpath(File::Spec->rel2abs(__FILE__)))[1]
);

use App::Config;

sub connect {
    my $dsn = sprintf(
        "dbi:Pg:dbname=%s;host=%s;port=%s",
        App::Config->get('DB_NAME'),
        App::Config->get('DB_HOST'),
        App::Config->get('DB_PORT') || '5432'
    );

    my $dbh = DBI->connect(
        $dsn,
        App::Config->get('DB_USER'),
        App::Config->get('DB_PASSWORD'),
        {
            RaiseError => 1,
            AutoCommit => 1
        }
    );

    return $dbh;
}

1;
