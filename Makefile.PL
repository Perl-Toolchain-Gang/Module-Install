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
author       'Adam Kennedy <adamk@cpan.org>';
perl_version '5.004';
all_from     'lib/Module/Install.pm';

install_as_cpan;

requires 'YAML::Tiny'        => '1.26';
requires 'Module::ScanDeps'  => '0.28';
requires 'Module::CoreList'  => 0;
requires 'PAR::Dist'         => '0.03';
requires 'Archive::Tar'      => '0.23';
requires 'ExtUtils::Install' => '0.3';
requires 'ExtUtils::ParseXS' => 0;
requires 'Module::Build'     => 0;

# Should be a "requires", but we should solve the
# "auto-include File::Spec if version < 5.005" problem first.
build_requires 'File::Spec'    => 0;

build_requires 'Test::Harness' => '2.03';
build_requires 'Test::More'    => '0.42';
build_requires 'File::Remove'  => '1.40';

# Makes the recursive test script run
tests_recursive;

# Ignore example files
no_index directory => 'example';

WriteAll;
