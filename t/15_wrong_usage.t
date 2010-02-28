#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use t::lib::Test;

plan tests => 4;

eval "require Capture::Tiny";
my $has_capture_tiny = $@ ? 0 : 1;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use Module::Install 0.81;  # should use "use inc::Module::Install"!
name          'Foo';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
WriteAll;
END_DSL

	my $home = File::Spec->rel2abs(File::Spec->curdir);
	if ($has_capture_tiny) {
		my $ret;
		my $out = Capture::Tiny::capture_merged(sub { $ret = build_dist('Foo') });
		ok !$ret, "build_dist failed";
		ok $out =~ /Please invoke Module::Install with/, "output: $out";
	}
	else {
		my $ret = build_dist('Foo');
		ok !$ret, "build_dist failed";
		SKIP: {
			skip "require Capture::Tiny to capture output", 1;
			pass "test skipped";
		}
	}
	chdir $home;

	ok( kill_dist('Foo'), 'kill_dist' );
}
