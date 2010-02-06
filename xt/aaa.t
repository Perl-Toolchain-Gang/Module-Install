#!/usr/bin/perl

# Author testing

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 1;

ok( 1, 'Running xt tests' );
