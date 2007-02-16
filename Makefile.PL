use strict;

# Warnings need to be enabled this way, because Makefile.PL is not
# a script, so we shouldn't be using a hashbang.
BEGIN {
	$^W = 1;
}

# NOTE: Module::Install's Makefile.PL needs this statement to bootstrap
# itself. Other module distributions using Module::Install do not need it.
# It causes inc::Module::Install to load from the (unique to this
# distribution) file ./lib/inc/Module/Install.pm instead of the system
# inc::Module::Install or the bundled inc/Module::Install.
use lib 'lib';
use inc::Module::Install;

name        'Module-Install';
author      'Audrey Tang <autrijus@autrijus.org>';
all_from    'lib/Module/Install.pm';

# Should be a "requires", but we should solve the
# "auto-include File::Spec if version < 5.005" problem first.
build_requires 'File::Spec'    => 0;

# We are going to move to Test::More shortly
build_requires 'Test::Harness' => '2.03';
build_requires 'Test::More'    => '0.42';

# Make sure we have at least one YAML parser
if ( is_admin() ) {
    # This is for META.yml
    requires 'YAML::Tiny' => '1.03';
}
elsif ( can_cc() ) {
    requires('YAML::Syck' => '0.27')
      unless can_use('YAML::Tiny' => '1.03') or can_use('YAML' => '0.35');
} else {
    requires('YAML::Tiny' => '1.03')
      unless can_use('YAML::Syck' => '0.27') or can_use('YAML::Tiny' => '1.03');
}

feature 'Include packages with full dependencies',
    recommends
        'Module::ScanDeps'  => 0.28,
        'Module::CoreList';

feature 'PAR-based binary distributions',
    recommends
        'PAR::Dist'         => 0.03;

feature 'Module::Build support',
    'Archive::Tar'      => 0.23,
    'ExtUtils::Install' => 0.3,
    'ExtUtils::ParseXS',
    recommends
        'Module::Build';

no_index
    directory => 'example';

auto_install
    prerequisites_policy => 'follow';
auto_provides;

# Disabled until someone who can sign is doing the releasing
# sign;

WriteAll;
