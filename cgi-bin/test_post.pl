#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON::PP;

my $method = $ENV{'REQUEST_METHOD'} || '';

my $body = '';

if ($method eq 'POST') {

    my $content_length = $ENV{'CONTENT_LENGTH'} || 0;

    read(STDIN, $body, $content_length);
}

my $cgi = CGI->new;

print "Content-Type: application/json\n\n";

if ($method eq 'POST') {

    my $data = decode_json($body);

    print encode_json(
        {
            recibido => $data
        }
    );

}
else {

    print encode_json(
        {
            error => 'Metodo no permitido'
        }
    );
}
