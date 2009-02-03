#!/usr/bin/perl

BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 6;
use File::Spec;
use t::lib::Test;

ok( create_dist('Foo'), 'create_dist' );
ok( build_dist('Foo'),  'build_dist'  );
ok( -f File::Spec->catfile(qw(t Foo META.yml)) );
ok( -f File::Spec->catfile(qw(t Foo MYMETA.yml)) );
ok( -f File::Spec->catfile(qw(t Foo inc Module Install.pm)) );
ok( kill_dist('Foo'),   'kill_dist'   );
