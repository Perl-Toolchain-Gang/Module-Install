#!perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use t::lib::Test;
use YAML::Tiny ();

plan tests => 7;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<'END_DSL' }), 'create_dist' );
use inc::Module::Install 0.82;

name          'Foo';
license       'rubharb';
author        'Foo Bar <foo@bar.com>';
all_from      'lib/Foo.pm';
requires      'perl'       => '5.008000';
test_requires 'Test::More' => '0.86';
no_index      'directory'  => qw{ t xt share inc };
install_share 'eg';
keywords      'kw1','kw 2';
keywords      'kw3';

WriteAll;
END_DSL

	unlink file('META.yml');
	unlink file('MYMETA.yml');
	ok( mkdir(dir('eg')), 'created eg/' );
	ok( add_file('eg/sample', 'This is a sample'), 'added sample' );
	ok( mkdir(dir('t')), 'created t/' );
	ok( add_file('t/01_comile.t', <<'END_TEST'), 'added test' );
#!/usr/bin/perl

BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 2;

ok( $] >= 5.005, 'Perl version is new enough' );

use_ok( 'Foo', 'Loaded Foo.pm' );
END_TEST

	is( build_dist(), 0, 'build dist failed with unknown license name' );
	ok( kill_dist(), 'kill dist' );
}
