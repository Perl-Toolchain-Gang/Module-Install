package Module::Install::Run;

use strict;
use Module::Install::Base;

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '0.85';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}

# eventually move the ipc::run / open3 stuff here.

1;
