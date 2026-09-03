package App::Config;

use strict;
use warnings;

use File::Spec;

# Carga y expone la configuracion de la aplicacion definida en el archivo
# .env que vive en la raiz del proyecto.
#
# Precedencia:
#   1. Variable de entorno del sistema (permite overrridear desde Docker
#      o el shell sin editar archivos).
#   2. Valor definido en el archivo .env.
#   3. undef si no esta en ningun lado.

my $_values;
my $_root_dir;

sub root_dir {
    my ($class) = @_;

    unless (defined $_root_dir) {
        my $lib_dir = File::Spec->rel2abs(__FILE__);
        my ($vol, $dirs) = File::Spec->splitpath($lib_dir);
        $dirs = File::Spec->catdir($dirs, '..', '..');
        $_root_dir = File::Spec->catpath($vol, $dirs, '');
    }

    return $_root_dir;
}

sub _env_file {
    my ($class) = @_;

    return File::Spec->catfile($class->root_dir, '.env');
}

sub _load {
    my ($class) = @_;

    return if defined $_values;

    $_values = {};

    my $file = $class->_env_file;

    return unless -f $file;

    open my $fh, '<', $file or return;

    while (my $line = <$fh>) {
        chomp $line;

        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;

        if ($line =~ /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/) {
            my ($key, $value) = ($1, $2);
            $_values->{$key} = $value;
        }
    }

    close $fh;
}

sub get {
    my ($class, $key) = @_;

    $class->_load;

    if (defined $ENV{$key} && $ENV{$key} ne '') {
        return $ENV{$key};
    }

    return $_values->{$key};
}

sub all {
    my ($class) = @_;

    $class->_load;

    my %merged = %$_values;

    foreach my $key (keys %merged) {
        if (defined $ENV{$key} && $ENV{$key} ne '') {
            $merged{$key} = $ENV{$key};
        }
    }

    return \%merged;
}

1;
