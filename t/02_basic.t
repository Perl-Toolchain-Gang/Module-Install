use Test;
use File::Spec;

plan(tests => 4);

ok(TestHelper->create_dist('Foo'));
ok(TestHelper->build_dist('Foo'));
ok(-f File::Spec->catfile(qw(t Foo inc Module Install.pm)));
ok(TestHelper->kill_dist('Foo'));

package TestHelper;
BEGIN {$^W = 1};
use strict;
use File::Spec;
use File::Path;
use Cwd;
use Config;

sub create_dist {
    my ($self, $dist) = @_;
    my $dist_path = File::Spec->catdir('t', $dist);
    return 0 if -d $dist_path;
    my $home = cwd;
    mkdir($dist_path, 0777) or return 0;
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
license 'perl';
WriteMakefile;
END_MAKEFILE_PL
    close MAKEFILE_PL;

    open MODULE, "> $dist.pm" or return 0;
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
    my ($self, $dist) = @_;
    my $dist_path = File::Spec->catdir('t', $dist);
    return 0 unless -d $dist_path;
    my $home = cwd;
    chdir $dist_path or return 0;
    system($^X, "-Ilib", "-Iblib/lib", "Makefile.PL") == 0 or return 0;
    chdir $home or return 0;
    return 1;
}

sub kill_dist {
    my ($self, $dist) = @_;
    my $dist_path = File::Spec->catdir('t', $dist);
    File::Path::rmtree($dist_path) or return 0;
    return 1; 
}

1;
