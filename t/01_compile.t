#!/usr/bin/perl

# Compile testing for Module::Install

use strict;
use vars qw{$VERSION};
BEGIN {
	$|       = 1;
	$^W      = 1;
	$VERSION = '0.74';
}

use Test::More tests => 62;

# Check their perl version
ok( $] >= 5.004, "Your perl is new enough" );

my @classes = qw{
	Module::Install::Base
	Module::Install::Admin
	Module::Install::AutoInstall
	Module::Install::Bundle
	Module::Install::Can
	Module::Install::Compiler
	Module::Install::Deprecated
	Module::Install::External
	Module::Install::Fetch
	Module::Install::Include
	Module::Install::Inline
	Module::Install::Makefile
	Module::Install::MakeMaker
	Module::Install::Metadata
	Module::Install::PAR
	Module::Install::Run
	Module::Install::Share
	Module::Install::Win32
	Module::Install::With
	Module::Install::WriteAll
	Module::Install::Admin::Bundle
	Module::Install::Admin::Find
	Module::Install::Admin::Include
	Module::Install::Admin::Makefile
	Module::Install::Admin::Manifest
	Module::Install::Admin::Metadata
	Module::Install::Admin::ScanDeps
	Module::Install::Admin::WriteAll
	Module::Install
	inc::Module::Install
};

# Load each class and check VERSIONs
foreach my $class ( @classes ) {
	eval "require $class;";
	ok( ! $@, "$class loads ok" );
	no strict 'refs';
	is( ${"${class}::VERSION"}, $VERSION, "$class \$VERSION matches" );
}

# Load the test class
use_ok( 't::lib::Test' );
