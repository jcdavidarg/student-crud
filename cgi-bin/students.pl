#!/usr/bin/perl

use strict;
use warnings;
use JSON::PP;


my $students = [
    {
        id       => 1,
        nombre   => 'David',
        apellido => 'Perez'
    },
    {
        id       => 2,
        nombre   => 'Juan',
        apellido => 'Gomez'
    }
];

print "Content-Type: application/json\n\n";

print encode_json($students);
