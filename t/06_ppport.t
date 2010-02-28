#!/usr/bin/perl

# Check that ppport works

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 1;

ok( -f 'ppport.h', 'Found ppport.h' );
