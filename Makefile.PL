# Normally we don't need strict, but for this one we'll do it anyway.
use strict;

# Warnings need to be enabled this way, because Makefile.PL is not
# an executable script (so we can't use a hashbang).
BEGIN {
	$|  = 1;
	$^W = 1;
}

# NOTE: Module::Install's Makefile.PL needs this "use lib 'lib'" to
# bootstrap itself. Other module distributions using Module::Install
# do not need it. It causes inc::Module::Install to load from the
# (unique to this distribution) file ./lib/inc/Module/Install.pm instead
# of the system inc::Module::Install or the bundled ./inc/Module/Install.pm
use lib 'lib';
use inc::Module::Install;

name          'Module-Install';
author        'Adam Kennedy <adamk@cpan.org>';
perl_version  '5.005';
all_from      'lib/Module/Install.pm';
requires      'Parse::CPAN::Meta' => '1.39';
requires      'File::Spec'        => '3.2701';
requires      'Devel::PPPort'     => '3.16';
requires      'File::Remove'      => '1.42';
requires      'YAML::Tiny'        => '1.38';
requires      'JSON'              => '2.14';
requires      'Module::ScanDeps'  => '0.89';
requires      'Module::CoreList'  => '2.17';
requires      'PAR::Dist'         => '0.29';
requires      'Archive::Tar'      => '1.44';
requires      'ExtUtils::Install' => '1.52';
requires      'ExtUtils::ParseXS' => '2.19';
requires      'Module::Build'     => '0.2804';
test_requires 'Test::Harness'     => '3.13';
test_requires 'Test::More'        => '0.86';

# Remove some extra test files
clean_files( qw{
	test/A/inc
	test/A/META.yml
	test/A/MYMETA.yml
	test/A/MYMETA.json
	test/A/Makefile
} );

# Test configure_requires support (also needed by WriteMyMeta)
configure_requires 'YAML::Tiny' => '1.33';

# Makes the recursive test script run
# (to test recursive test support)
tests_recursive;

# This isn't needed, but lets us test File::ShareDir support
install_share;

# This isn't needed, but lets us test Devel::PPPort support
ppport;

# This is a normal CPAN module
install_as_cpan;

# Normally this shouldn't be done in here, it should be done
# by release automation. This is mostly for testing reasons.
repository 'http://svn.ali.as/cpan/trunk/Module-Install';

WriteAll;
