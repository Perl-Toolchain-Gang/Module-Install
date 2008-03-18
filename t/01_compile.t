#!/usr/bin/perl

# Load testing for File::PathList

use strict;
use vars qw{$VERSION};
BEGIN {
	$|       = 1;
	$^W      = 1;
	$VERSION = '0.70';
}

use Test::More tests => 4;

# Check their perl version
ok( $] >= 5.005, "Your perl is new enough" );

# Does the module load
require_ok('inc::Module::Install');

# Verify the core modules loaded
foreach my $class ( qw{inc::Module::Install Module::Install} ) {
	no strict 'refs';
	is( ${"${class}::VERSION"}, $VERSION, "VERSION matches - $class" );
}
