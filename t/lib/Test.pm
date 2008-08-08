package t::lib::Test;

use strict;
use File::Spec;
use File::Remove 'remove';
use Cwd;
use Config;

use vars qw{$VERSION @ISA @EXPORT};
BEGIN {
	$VERSION = '0.77';
	@ISA     = 'Exporter';
	@EXPORT  = qw{
		create_dist
		build_dist
		kill_dist
	};
}

sub create_dist {
	my $dist      = shift;

	# Clear out any existing directory
	kill_dist( $dist );


	my $home      = cwd;
	my $dist_path = File::Spec->catdir('t', $dist);
	my $dist_lib  = File::Spec->catdir('t', $dist, 'lib');
	mkdir($dist_path, 0777) or return 0;
	mkdir($dist_lib,  0777) or return 0;
	chdir $dist_path        or return 0;

	open MANIFEST, '> MANIFEST' or return 0;
	print MANIFEST <<"END_MANIFEST";
MANIFEST
Makefile.PL
$dist.pm
END_MANIFEST
	close MANIFEST;

	open MAKEFILE_PL, '> Makefile.PL' or return 0;
	print MAKEFILE_PL <<"END_MAKEFILE_PL";
use inc::Module::Install;
name    '$dist';
license 'perl';
WriteMakefile;
END_MAKEFILE_PL
	close MAKEFILE_PL;

	open MODULE, "> lib/$dist.pm" or return 0;
	print MODULE <<"END_PERL_MODULE";
package $dist;
\$VERSION = '3.21';
use strict;

1;

__END__

=head1 NAME

$dist - A test module

=cut
END_PERL_MODULE
	close MODULE;
	chdir $home or return 0;
	return 1;
}

sub build_dist {
	my $dist      = shift;
	my $dist_path = File::Spec->catdir('t', $dist);
	return 0 unless -d $dist_path;
	my $home = cwd;
	chdir $dist_path or return 0;
	system($^X, "-I../../lib", "-I../../blib/lib", "Makefile.PL") == 0 or return 0;
	chdir $home or return 0;
	return 1;
}

sub kill_dist {
	my $dist = shift;
	my $dir = File::Spec->catdir('t', $dist);
	return 1 unless -d $dir;
	remove( \1, $dir );
	return -d $dir ? 0 : 1;
}

1;
