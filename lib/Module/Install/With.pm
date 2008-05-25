package Module::Install::With;

### HIGHLY EXPERIMENTAL - TALK TO ADAMK BEFORE USING ANY OF THESE COMMANDS

# Provides chunks of functionality for detecting with and interacting with
# the rest of the toolchain, helping Module::Install play well with others.
#
# That is CPAN vs CPANPLUS vs standalone, and EUMM vs MB.

use strict;
use Module::Install::Base;
use File::Spec ();

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '0.74';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}





#####################################################################
# Installer Target

# Are we targeting ExtUtils::MakeMaker (running as Makefile.PL)
sub eumm {
	!! ($0 =~ /Makefile.PL$/i);
}

# You should not be using this, but we'll keep the hook anyways
sub mb {
	!! ($0 =~ /Build.PL$/i);
}




#####################################################################
# Testing and Configuration Contexts

# Are we in an interactive configuration environment
sub interactive {
	# Treat things interactively ONLY based on input
	!! -t STDIN;
}

# Are we currently running under some sort of automated testing system
sub automated_testing {
	!! $ENV{AUTOMATED_TESTING};
}

sub user_context {
	! $Module::Install::AUTHOR;
}

sub author_context {
	!! $Module::Install::AUTHOR;
}

1;
