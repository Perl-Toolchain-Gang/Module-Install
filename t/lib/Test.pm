package t::lib::Test;

use strict;
use File::Spec   ();
use File::Remove ();
use Cwd;
use Config;

use vars qw{$VERSION @ISA @EXPORT $DIST};
BEGIN {
	$VERSION = '0.94';
	@ISA     = 'Exporter';
	@EXPORT  = qw{
		create_dist
		build_dist
		kill_dist
		run_makefile_pl
		add_file
		add_test
		_read
		file dir
		makefile
	};
	$DIST = '';
}

# Done in evals to avoid confusing Perl::MinimumVersion
eval( $] >= 5.006 ? <<'END_NEW' : <<'END_OLD' ); die $@ if $@;
sub _read {
	local *FH;
	open( FH, '<', $_[0] ) or die "open($_[0]): $!";
	my $string = do { local $/; <FH> };
	close FH or die "close($_[0]): $!";
	return $string;
}
END_NEW
sub _read {
	local *FH;
	open( FH, "< $_[0]"  ) or die "open($_[0]): $!";
	my $string = do { local $/; <FH> };
	close FH or die "close($_[0]): $!";
	return $string;
}
END_OLD

sub create_dist {
	$DIST = shift;
	my $opt  = shift || {};

	# Clear out any existing directory
	kill_dist( $DIST );

	my $home      = cwd;
	my $dist_path = dir();
	my $dist_lib  = dir('lib');
	mkdir($dist_path, 0777) or return 0;
	mkdir($dist_lib,  0777) or return 0;
	chdir($dist_path      ) or return 0;

	# Write the MANIFEST
	open( MANIFEST, '>MANIFEST' ) or return 0;
	print MANIFEST $opt->{MANIFEST} || <<"END_MANIFEST";
MANIFEST
Makefile.PL
lib/$DIST.pm
END_MANIFEST
	close MANIFEST;

	# Write the configure script
	open MAKEFILE_PL, '>Makefile.PL' or return 0;
	print MAKEFILE_PL $opt->{'Makefile.PL'} || <<"END_MAKEFILE_PL";
use inc::Module::Install 0.81;
name          '$DIST';
version       '0.01';
license       'perl';
requires_from 'lib/$DIST.pm';
requires      'File::Spec' => '0.79';
WriteAll;
END_MAKEFILE_PL
	close MAKEFILE_PL;

	# Write the module file
	open MODULE, ">lib/$DIST.pm" or return 0;
	print MODULE $opt->{"lib/$DIST.pm"} || <<"END_MODULE";
package $DIST;

\$VERSION = '3.21';

use strict;
use File::Spec 0.80;

1;

__END__

=head1 NAME

$DIST - A test module

=head1 AUTHORS

Foo Bar

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
END_MODULE
	close MODULE;

	chdir $home or return 0;
	return 1;
}

sub file { File::Spec->catfile('t', $DIST, @_) }
sub dir  { File::Spec->catdir('t', $DIST, @_) }
sub makefile { file( $^O eq 'VMS' ? 'Descrip.MMS' : 'Makefile' ) }

sub add_file {
	my ($path, $content) = @_;
	my $dist_path = dir();
	return 0 unless -d $dist_path;

	my ($vol, $subdir, $file) = File::Spec->splitpath($path);
	my $dist_subdir = dir($subdir);
	my $dist_file   = file($subdir, $file);
	unless (-d $dist_subdir) {
		mkdir($dist_subdir, 0777) or return 0;
	}

	open FILE, "> $dist_file" or return 0;
	print FILE $content;
	close FILE;

	return 1;
}

sub add_test { add_file(@_, qq{print "1..1\nok 1\n";}) }

sub build_dist {
	my %params = @_;
	my $dist_path = dir();
	return 0 unless -d $dist_path;
	my $home = cwd;
	chdir $dist_path or return 0;
	my $X_MYMETA = $params{MYMETA} || '';
	local $ENV{X_MYMETA} = $X_MYMETA;

	my @run_params=@{ $params{run_params} || [] };
	system($^X, "-I../../lib", "-I../../blib/lib", "Makefile.PL",@run_params) == 0 or return 0;
	chdir $home or return 0;
	return 1;
}

sub run_makefile_pl {
	my %params = @_;
	my $dist_path = dir();
	return 0 unless -d $dist_path;
	my $home = cwd;
	chdir $dist_path or return 1;
	my $X_MYMETA = $params{MYMETA} || '';
	local $ENV{X_MYMETA} = $X_MYMETA;

	my $run_params=join(' ',@{ $params{run_params} || [] });
	system("$^X -I../../lib -I../../blib/lib Makefile.PL $run_params") == 0 or return 0;
	#my $result=qx();
	chdir $home or return 0;
	return 1;
}

sub kill_dist {
	my $dir = dir();
	return 1 unless -d $dir;
	File::Remove::remove( \1, $dir );
	return -d $dir ? 0 : 1;
}

1;
