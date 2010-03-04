#!/usr/bin/perl

# Check that ppport works

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use t::lib::Test;

eval "require Devel::PPPort";
plan skip_all => 'requires Devel::PPPort' if $@;

plan tests => 8;

SCOPE: {
	#ok( create_dist('Foo'), 'create_dist' );
        ok( create_dist( 'Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
all_from      'lib/Foo.pm';
perl_version  '5.005';
WriteAll;
END_DSL

	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo ppport.h));
	ok( !-f $file, 'Not found ppport.h');
	ok( kill_dist('Foo'), 'kill_dist' );
}

SCOPE: {
	#ok( create_dist('Foo'), 'create_dist' );
        ok( create_dist( 'Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
all_from      'lib/Foo.pm';
perl_version  '5.005';
ppport;
WriteAll;
END_DSL

	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo ppport.h));
	ok( -f $file, 'Found ppport.h');
	ok( kill_dist('Foo'), 'kill_dist' );
}

