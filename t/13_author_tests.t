#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use t::lib::Test;

plan tests => 15;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
version       '0.01';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
WriteAll;
END_DSL

	ok( add_test('Foo', 'xt/test.t'), 'added xt' );
	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo Makefile));
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	diag my ($testline) = $content =~ /^#\s*(test => .+)$/m;
	ok($content =~ /#\s*test => { TESTS=>.+xt\/\*\.t/, 'has xt/*.t');
	ok( kill_dist('Foo'), 'kill_dist' );
}

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
version       '0.01';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
WriteAll;
END_DSL

	ok( add_test('Foo', 'xt/test.t'), 'added xt' );
	ok( build_dist('Foo'), 'build_dist' );
	rmdir File::Spec->catdir(qw(t Foo inc .author)); # non-author-mode
	unlink File::Spec->catdir(qw(t Foo Makefile));
	ok( run_makefile_pl('Foo'), 'build_dist again' );
	my $file = File::Spec->catfile(qw(t Foo Makefile));
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	diag my ($testline) = $content =~ /^#\s*(test => .+)$/m;
	if ( $ENV{RELEASE_TESTING} ) {
		ok($content =~ /#\s*test => { TESTS=>.+xt\/\*\.t/, 'has xt/*.t');
	} else {
		ok($content !~ /#\s*test => { TESTS=>.+xt\/\*\.t/, 'has no xt/*.t');
	}
	ok( kill_dist('Foo'), 'kill_dist' );
}
