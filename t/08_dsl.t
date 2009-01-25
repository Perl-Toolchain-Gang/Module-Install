#!/usr/bin/perl

# Tests for Module::Install::DSL
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 2;

# Load the DSL module
require_ok( 'Module::Install::DSL' );

# Generate code from a simple dsl block
my $code = Module::Install::DSL::dsl2code(<<'END_DSL');
all_from lib/My/Module.pm
requires perl 5.008
requires Carp 0
requires Win32 if win32
test_requires Test::More
install_share
END_DSL

is( $code, <<'END_PERL', 'dsl2code generates the expected code' );
all_from 'lib/My/Module.pm';
requires 'perl', '5.008';
requires 'Carp', '0';
requires 'Win32' if win32;
test_requires 'Test::More';
install_share;
END_PERL
