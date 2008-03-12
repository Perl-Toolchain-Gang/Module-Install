package Module::Install::AutoInstall;

use strict;
use Carp ();
use Module::Install::Base;

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '0.69';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}

sub AutoInstall {
    Carp::croak('Module::Install::AutoInstall often breaks CPAN and has been deprecated');
}

sub run {
    Carp::croak('Module::Install::AutoInstall often breaks CPAN and has been deprecated');
}

sub write {
    Carp::croak('Module::Install::AutoInstall often breaks CPAN and has been deprecated');
}

sub auto_install {
    Carp::croak('Module::Install::AutoInstall often breaks CPAN and has been deprecated');
}

sub auto_install_now {
    Carp::croak('Module::Install::AutoInstall often breaks CPAN and has been deprecated');
}

1;
