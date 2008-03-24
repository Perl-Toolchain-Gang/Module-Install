#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 13;
require_ok( 'inc::Module::Install' );

my @data = qw{
	0      0
	1      1
	1.1    1.1
	1234   1234
	1.2.3  1.2003
	1.2_01 1.20001
};

while ( @data ) {
	my $in  = shift @data;
	my $out = shift @data;
	my $ver = Module::Install::_version($in);
	my $two = Module::Install::_version($ver);
	is( $ver, $out, "$in => $out pass 1 ok" );
	is( $two, $out, "$in => $out pass 2 ok" );
}
