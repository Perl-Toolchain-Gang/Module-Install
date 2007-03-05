#!/usr/bin/perl -w

# Load testing for File::PathList

use strict;
use lib ();
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		$FindBin::Bin = $FindBin::Bin; # Avoid a warning
		chdir catdir( $FindBin::Bin, updir() );
		lib->import(
			catdir('blib', 'lib'),
			'lib',
			);
	}
}

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.65';
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

exit(0);
