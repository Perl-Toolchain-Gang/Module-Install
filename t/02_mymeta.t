#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 24;
use File::Spec;
use t::lib::Test;

# Regular build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( build_dist('Foo'),  'build_dist'  );
	ok( -f File::Spec->catfile(qw(t Foo Makefile)) );
	ok( -f File::Spec->catfile(qw(t Foo META.yml)) );
	ok( ! -f File::Spec->catfile(qw(t Foo MYMETA.yml)) );
	ok( ! -f File::Spec->catfile(qw(t Foo MYMETA.json)) );
	ok( -f File::Spec->catfile(qw(t Foo inc Module Install.pm)) );
	ok( kill_dist('Foo'),   'kill_dist'   );
}

# MYMETA.yml build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( build_dist('Foo', MYMETA => 'YAML' ),  'build_dist'  );
	ok( -f File::Spec->catfile(qw(t Foo Makefile)) );
	ok( -f File::Spec->catfile(qw(t Foo META.yml)) );
	ok( -f File::Spec->catfile(qw(t Foo MYMETA.yml)) );
	ok( ! -f File::Spec->catfile(qw(t Foo MYMETA.json)) );
	ok( -f File::Spec->catfile(qw(t Foo inc Module Install.pm)) );
	ok( kill_dist('Foo'),   'kill_dist'   );
}

# MYMETA.json build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( build_dist('Foo', MYMETA => 'JSON' ),  'build_dist'  );
	ok( -f File::Spec->catfile(qw(t Foo Makefile)) );
	ok( -f File::Spec->catfile(qw(t Foo META.yml)) );
	ok( ! -f File::Spec->catfile(qw(t Foo MYMETA.yml)) );
	ok( -f File::Spec->catfile(qw(t Foo MYMETA.json)) );
	ok( -f File::Spec->catfile(qw(t Foo inc Module Install.pm)) );
	ok( kill_dist('Foo'),   'kill_dist'   );
}
