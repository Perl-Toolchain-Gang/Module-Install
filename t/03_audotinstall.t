#!/usr/bin/perl

use strict;
use Test;

BEGIN { plan tests => 6; $^W = 0; };

# Intercepts calls to WriteMakefile and prompt.
my $mm_args;
my @prompts = qw/y n n y y/;

use ExtUtils::MakeMaker;
sub ExtUtils::MakeMaker::WriteMakefile { $mm_args = {@_} }
sub ExtUtils::MakeMaker::prompt ($;$) { return 'n' }

# tiehandle trick to intercept STDOUT.
sub PRINT     { my $self = shift; $$self .= join '', @_; }
sub PRINTF    { my $self = shift; $$self .= sprintf(shift, @_); }
sub TIEHANDLE { my $self = ''; return bless \$self, shift; }
sub READ      {}
sub READLINE  {}
sub GETC      {}
sub FILENO    {}

require Symbol;
my $fh  = Symbol::gensym;
my $out = tie *$fh, __PACKAGE__;
select(*$fh);

# test from a clean state
$ENV{PERL_AUTOINSTALL} = '';
require Module::AutoInstall;
Module::AutoInstall::_accept_default(0);
*Module::AutoInstall::_prompt  = sub {
    ok($_[1], shift(@prompts));
    return 'n';
};

# calls the module.
ok(eval <<'.', $@);
use Module::AutoInstall (
    -version    => '0.21',      # Module::AutoInstall version
    -config     => {
        make_args => '--hello'  # option(s) for CPAN::Config 
    },
    -core       => [            # core modules
        Package0  => '',        # any version would do
    ],
    'Feature1'  => [
        # do we want to install this feature by default?
        -default  => 0,
        Package1  => '0.01',
    ],
    'Feature2'  => [
        # associate tests to be disabled along with this
        -tests    => [ $0 ],
        Package2  => '0.02',
    ],
    'Feature3'  => {            # hash reference works, too
        Package3  => '0.03',
    },
); '';
.

# simulates a makefile.
WriteMakefile(
    AUTHOR              => 'Zoe Hacker <joe@hacker.org>',
    ABSTRACT            => 'Perl Interface to Zoe Hacker',
    NAME                => 'Zoe::Hacker',
    VERSION_FROM        => 'Hacker.pm',
    DISTNAME            => 'Zoe-Hacker',
    EXE_FILES           => [ qw/foo bar baz/ ],
);

# XXX - test currently disabled in anticipation of a
#       rewrite using Test::MockObject.

__END__
use Data::Dumper;

$$out =~ s/.*\n//; # strip the version-dependent line.

ok($$out =~ /\Q*** Checking for dependencies...
[Core Features]
- Package0 ...failed! (needed)
[Feature1]
- Package1 ...failed! (needs 0.01)
[Feature2]
- Package2 ...failed! (needs 0.02)
[Feature3]
- Package3 ...failed! (needs 0.03)\E
.*\Q
*** Module::AutoInstall configuration finished.\E/s);

use vars qw/@Data_Stack $DNE/;
$mm_args->{test}{TESTS} = ''; # XXX: workaround false-positive globbing

ok(
    Data::Dumper::Dumper($mm_args), 
    Data::Dumper::Dumper({
        ABSTRACT        => 'Perl Interface to Zoe Hacker',
        test            =>  { 'TESTS' => '' },
        NAME            => 'Zoe::Hacker',
        DISTNAME        => 'Zoe-Hacker',
        AUTHOR          => 'Zoe Hacker (joe@hacker.org)',
        EXE_FILES       => [],
        VERSION_FROM    => 'Hacker.pm',
    })
);
