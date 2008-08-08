#!/usr/bin/perl

# Check that install_share 

use strict;
use vars qw{$VERSION};
BEGIN {
	$|       = 1;
	$^W      = 1;
	$VERSION = '0.77';
}

use Test::More tests => 2;
use File::Spec::Functions ':ALL';

# Where should the share dir be
my $dir = catdir(qw{ blib lib auto share dist Module-Install });
ok( -d $dir, 'Found install_share in correct dist_dir location' );

# Where should the share file be
my $file = catfile( $dir, 'dist_file.txt' );
ok( -f $file, 'Found expected file in dist_dir location' );
