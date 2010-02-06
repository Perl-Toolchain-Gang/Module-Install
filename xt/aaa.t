#!/usr/bin/perl

# Author testing

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 1;

ok( $ENV{RELEASE_TESTING}, 'RELEASE_TESTING is enabled' );
