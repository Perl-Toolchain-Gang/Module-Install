# Normally we don't need to use strict, but for this one we'll
# do it anyway.
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
# of the system inc::Module::Install or the bundled inc/Module::Install.
use lib 'lib';
use inc::Module::Install 0.75;

name          'Module-Install';
author        'Adam Kennedy <adamk@cpan.org>';
perl_version  '5.004';
repository    'http://svn.ali.as/cpan/trunk/Module-Install';
all_from      'lib/Module/Install.pm';
requires      'YAML::Tiny'        => '1.31';
requires      'Module::ScanDeps'  => '0.83';
requires      'Module::CoreList'  => '2.15';
requires      'PAR::Dist'         => '0.29';
requires      'Archive::Tar'      => '1.38';
requires      'ExtUtils::Install' => '1.50';
requires      'ExtUtils::ParseXS' => '2.19';
requires      'Module::Build'     => '0.2808';
test_requires 'Test::Harness'     => '2.03';
test_requires 'Test::More'        => '0.42';
test_requires 'File::Remove'      => '1.40';

# Should be a "requires", but we have to solve the
# "auto-include File::Spec if version < 5.005" problem first.
test_requires 'File::Spec'        => '0.80';

# Makes the recursive test script run
# (to test recursive test support)
tests_recursive;

install_as_cpan;

WriteAll;
