#!/usr/bin/perl -w
use strict;

BEGIN {
        $|  = 1;
        $^W = 1;
}

use Test::More tests => 4;
require_ok( 'Module::Install::Metadata' );

my $metadata = Module::Install::Metadata->new;

$metadata->perl_version('5.008');
is($metadata->perl_version, 5.008);

$metadata->perl_version('5.8.1');
is($metadata->perl_version, 5.008001);

$metadata->perl_version('5.10.1');
is($metadata->perl_version, 5.010001);
