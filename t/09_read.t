#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 4;
use File::Spec::Functions ':ALL';
require_ok( 'inc::Module::Install' );

my $file = catfile('test', 'A', 'lib', 'A.pm');
ok( -f $file, "Found test file '$file'" );

# Test _readpod
my $pod = Module::Install::_readpod($file);
is( $pod, <<'END_POD', "_readpod($file)" );
=head1 NAME

A - Trivial test module

=head1 DESCRIPTION

This file is used to test the _readperl and _readpod functions

END_POD

# Test _readperl
my $perl = Module::Install::_readperl($file);
is( $perl, <<'END_PERL', "_readperl($file)" );
package A;

use 5.005;

$VERSION = '0.01';

1;
END_PERL
