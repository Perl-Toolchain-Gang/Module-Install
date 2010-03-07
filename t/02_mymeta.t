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
	ok( build_dist(), 'build_dist' );
	ok( -f makefile() );
	ok( -f file('META.yml') );
	ok( ! -f file('MYMETA.yml') );
	ok( ! -f file('MYMETA.json') );
	ok( -f file(qw(inc Module Install.pm)) );
	ok( kill_dist(), 'kill_dist' );
}

# MYMETA.yml build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( build_dist( MYMETA => 'YAML' ), 'build_dist' );
	ok( -f makefile() );
	ok( -f file('META.yml') );
	ok( -f file('MYMETA.yml') );
	ok( ! -f file('MYMETA.json') );
	ok( -f file(qw(inc Module Install.pm)) );
	ok( kill_dist(), 'kill_dist' );
}

# MYMETA.json build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( build_dist( MYMETA => 'JSON' ), 'build_dist' );
	ok( -f makefile() );
	ok( -f file('META.yml') );
	ok( ! -f file('MYMETA.yml') );
	ok( -f file('MYMETA.json') );
	ok( -f file(qw(inc Module Install.pm)) );
	ok( kill_dist(), 'kill_dist' );
}
