use strict;

# Warnings need to be enabled this way, because Makefile.PL is not
# an executable script (so we can't use a hashbang).
BEGIN {
	$|  = 1;
	$^W = 1;
}

# NOTE: Module::Install's Makefile.PL needs this statement to bootstrap
# itself. Other module distributions using Module::Install do not need it.
# It causes inc::Module::Install to load from the (unique to this
# distribution) file ./lib/inc/Module/Install.pm instead of the system
# inc::Module::Install or the bundled inc/Module::Install.
use lib 'lib';
use inc::Module::Install;

name         'Module-Install';
author       'Audrey Tang <autrijus@autrijus.org>';
perl_version '5.004';
all_from     'lib/Module/Install.pm';

install_as_cpan;

# Make sure we have at least one YAML parser
if ( is_admin() ) {
	# This is for META.yml
	requires 'YAML::Tiny' => '1.03';

} elsif ( can_cc() ) {
	can_use('YAML::Tiny' => '1.03')
	or
	can_use('YAML' => '0.35')
	or
	requires('YAML::Syck' => '0.27');

} else {
	can_use('YAML::Syck' => '0.27')
	or
	can_use('YAML::Tiny' => '1.03')
	or
	requires('YAML::Tiny' => '1.03');
}

# Removing the distinction of "recommends" as this overly-complicates
# the situation. Only authors should ever be installing this, so they
# can just have the lot.

# feature 'Include packages with full dependencies',
requires 'Module::ScanDeps' => '0.28';
requires 'Module::CoreList';

# feature 'PAR-based binary distributions',
requires 'PAR::Dist' => '0.03';

# We need Module::Build for certain functionality
requires 'Archive::Tar'      => '0.23';
requires 'ExtUtils::Install' => '0.3';
requires 'ExtUtils::ParseXS';
requires 'Module::Build';

# Should be a "requires", but we should solve the
# "auto-include File::Spec if version < 5.005" problem first.
build_requires 'File::Spec'    => 0;

# We are going to move to Test::More shortly
build_requires 'Test::Harness' => '2.03';
build_requires 'Test::More'    => '0.42';

# Makes the recursive test script run
tests_recursive;

# Ignore example files
no_index directory => 'example';

WriteAll;
