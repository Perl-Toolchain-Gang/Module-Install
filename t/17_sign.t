#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use t::lib::Test;

plan tests => 14;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
version       '0.01';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
WriteAll(sign => 0);
END_DSL

	ok( add_test('Foo', 'xt/test.t'), 'added xt' );
	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo Makefile));
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content !~ /#\s*SIGN => q\[[01]\]/, 'has no sign');
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
WriteAll(sign => 1);
END_DSL

	ok( add_test('Foo', 'xt/test.t'), 'added xt' );
	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo Makefile));
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content =~ /#\s*SIGN => q\[1\]/, 'has sign');
	ok( kill_dist('Foo'), 'kill_dist' );
}
