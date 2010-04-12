package Module::Install::Bundle;

use strict;
use Cwd                   ();
use File::Find            ();
use File::Copy            ();
use File::Basename        ();
use Module::Install::Base ();

use vars qw{$VERSION @ISA $ISCORE};
BEGIN {
	$VERSION = '0.95';
	@ISA     = 'Module::Install::Base';
	$ISCORE  = 1;
}

sub auto_bundle {
    my $self = shift;

    # Flatten array of arrays into a single array
    my @core = map @$_, map @$_, grep ref, $self->requires;

    $self->bundle(@core);
}

sub bundle {
    my $self = shift;

    # As admin, fetch these distributions in CPAN and put them in inc/BUNDLES
    $self->admin->bundle(@_) if $self->is_admin;

    # Distribution names and directory
    my $cwd = Cwd::cwd();
    my $bundles = $self->read_bundles;
    my $bundle_dir = $self->_top->{bundle};
    $bundle_dir =~ s/\W+/\\W+/g;

    while (my ($mod_name, $version) = splice(@_, 0, 2)) {
        $version ||= 0;

        my $dist_source_dir = $bundles->{$mod_name};
        if (not $dist_source_dir) {
            warn "Warning: It appears that the module $mod_name is missing. Report the issue to the author of this package.\n";
            next;
        }
        # State in META.yml that this module is bundled in the package
        $self->bundles($mod_name, $dist_source_dir);

        # Skip to next module if module is already installed
        next if eval "use $mod_name $version (); 1";

        # Move distribution to package root for deployment by make
        my $dist_target_dir = File::Basename::basename($dist_source_dir);
        mkdir( $dist_target_dir, 0777 ) or die $! unless -d $dist_target_dir;
        File::Find::find({
            wanted => sub {
                my $out = $_;
                $out =~ s/$bundle_dir/./i;
                mkdir( $out, 0777 ) if -d;
                File::Copy::copy($_ => $out) unless -d;
            },
            no_chdir => 1,
        }, $dist_source_dir);

        # Delete this build directory upon "make clean"
        $self->clean_files( $dist_target_dir );

        # Append the build dir in MANIFEST.SKIP to avoid having it in MANIFEST
        # XXX - need to actually read the content of the file to prevent adding an entry that already exists
        # XXX - ideally, we should read this file once and write in it only once too...
        # XXX - having a dedicated method for this somewhere would be convenient
        my $file = 'MANIFEST.SKIP';
        open my $fh, '>>', $file or die "Error: could not write file $file\n$!\n";
        print $fh "$dist_target_dir\n";
        print $fh "$file\n";
        close $fh;
    }

    chdir $cwd;
}

sub read_bundles {
    my $self = shift;
    my %map;

    local *FH;
    open FH, $self->_top->{bundle} . ".yml" or return {};
    while (<FH>) {
        /^(.*?): (['"])?(.*?)\2$/ or next;
        $map{$1} = $3;
    }
    close FH;

    return \%map;
}


sub auto_bundle_deps {
    my $self = shift;

    # Flatten array of arrays into a single array
    my @core = map @$_, map @$_, grep ref, $self->requires;
    while (my ($name, $version) = splice(@core, 0, 2)) {
        next unless $name;
         $self->bundle_deps($name, $version);
    }
}

sub bundle_deps {
    my ($self, $pkg, $version) = @_;
    my $deps = $self->admin->scan_dependencies($pkg);
    if (scalar keys %$deps == 0) {
        # Probably a user trying to install the package, read the dependencies from META.yml
        %$deps = ( map { $$_[0] => undef } (@{$self->requires()}) );
    }
    foreach my $key (sort keys %$deps) {
        $self->bundle($key, ($key eq $pkg) ? $version : 0);
    }
}

1;

__END__

=pod

=head1 NAME

Module::Install::Bundle - Bundle distributions along with your distribution

=head1 SYNOPSIS

Have your Makefile.PL read as follows:

  use inc::Module::Install;
  
  name      'Foo-Bar';
  all_from  'lib/Foo/Bar.pm';
  requires  'Baz' => '1.60';
  
  # one of either:
  bundle    'Baz' => '1.60';
  # OR:
  auto_bundle;
  
  WriteAll;

=head1 DESCRIPTION

Module::Install::Bundle allows you to bundle a CPAN distribution within your
distribution. When your end-users install your distribution, the bundled
distribution will be installed along with yours, unless a newer version of
the bundled distribution already exists on their local filesystem.

While bundling will increase the size of your distribution, it has several
benefits:

  Allows installation of bundled distributions when CPAN is unavailable
  Allows installation of bundled distributions when networking is unavailable
  Allows everything your distribution needs to be packaged in one place

Bundling differs from auto-installation in that when it comes time to
install, a bundled distribution will be installed based on the distribution
bundled with your distribution, whereas with auto-installation the distibution
to be installed will be acquired from CPAN and then installed.

=head1 METHODS

=over 4

=item * auto_bundle()

Takes no arguments, will bundle every distribution specified by a C<requires()>.
When you, as a module author, do a C<perl Makefile.PL> the latest versions of
the distributions to be bundled will be acquired from CPAN and placed in
F<inc/BUNDLES/>.

=item * bundle($name, $version)

Takes a list of key/value pairs specifying a distribution name and version
number. When you, as a module author, do a perl Makefile.PL the distributions
that you specified with C<bundle()> will be acquired from CPAN and placed in
F<inc/BUNDLES/>.

=item * bundle_deps($name, $version)

Same as C<bundle>, except that all dependencies of the bundled modules are
also detected and bundled.  To use this function, you need to declare the
minimum supported perl version first, like this:

    perl_version( '5.005' );

=item * auto_bundle_deps

Same as C<auto_bundle>, except that all dependencies of the bundled
modules are also detected and bundled. This function has the same constraints as bundle_deps.

=back

=head1 BUGS

Please report any bugs to (patches welcome):

    http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-Install

=head1 AUTHORS

Audrey Tang E<lt>autrijus@autrijus.orgE<gt>

Documentation by Adam Foxson E<lt>afoxson@pobox.comE<gt>

=head1 COPYRIGHT

Copyright 2003, 2004, 2005 by Audrey Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
