package Module::Install::Admin::Compiler;

use strict;
use Module::Install::Base;
use File::Remove  ();
use Devel::PPPort ();

use vars qw{$VERSION @ISA};
BEGIN {
	$VERSION = '0.77';
	@ISA     = qw{Module::Install::Base};
}

sub ppport {
	my $self   = shift;
	my $file   = shift || 'ppport.h';
	if ( -f $file ) {
		# Update the file to a newer version
		File::Remove::remove($file);
		Devel::PPPort::WriteFile( $file ) or die "Failed to write $file";
	} else {
		# Install the file (and remove on realclean)
		Devel::PPPort::WriteFile( $file ) or die "Failed to write $file";
		$self->realclean_files( $file );
	}
}

1;
