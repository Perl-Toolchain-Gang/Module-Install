package Module::Install::MakeMaker;

use strict;
use ExtUtils::MakeMaker   ();
use Module::Install::Base ();

use vars qw{$VERSION @ISA $ISCORE};
BEGIN {
	$VERSION = '1.20';
	@ISA     = 'Module::Install::Base';
	$ISCORE  = 1;
}

my $makefile = undef;

sub WriteMakefile {
    my ($self, %args) = @_;
    $makefile = $self->load('Makefile');

    # mapping between MakeMaker and META.yml keys
    $args{MODULE_NAME} = $args{NAME};
    unless ( $args{NAME} = $args{DISTNAME} or ! $args{MODULE_NAME} ) {
        $args{NAME} = $args{MODULE_NAME};
        $args{NAME} =~ s/::/-/g;
    }

    foreach my $key ( qw{name module_name version version_from abstract author installdirs} ) {
        my $value = delete($args{uc($key)}) or next;
        $self->$key($value);
    }

    if (my $prereq = delete($args{PREREQ_PM})) {
        while (my($k,$v) = each %$prereq) {
            $self->requires($k,$v);
        }
    }

    if (my $prereq = delete($args{BUILD_REQUIRES})) {
        while (my($k,$v) = each %$prereq) {
            $self->build_requires($k,$v);
        }
    }

    # put the remaining args to makemaker_args
    $self->makemaker_args(%args);
}

END {
    if ( $makefile ) {
        $makefile->write;
        $makefile->Meta->write;
    }
}

1;

=pod

=head1 NAME

Module::Install::MakeMaker - Extension Rules for ExtUtils::MakeMaker

=head1 SYNOPSIS

In your F<Makefile.PL>:

    use inc::Module::Install;
    WriteMakefile();

=head1 DESCRIPTION

This module is a wrapper around B<ExtUtils::MakeMaker>.  It exports
two functions: C<prompt> (an alias for C<ExtUtils::MakeMaker::prompt>)
and C<WriteMakefile>.

The C<WriteMakefile> function will pass on keyword/value pair functions
to C<ExtUtils::MakeMaker::WriteMakefile>. The required parameters
C<NAME> and C<VERSION> (or C<VERSION_FROM>) are not necessary if
it can find them unambiguously in your code.

=head1 CONFIGURATION OPTIONS

This module also adds some Configuration parameters of its own:

=head2 NAME

The NAME parameter is required by B<ExtUtils::MakeMaker>. If you have a
single module in your distribution, or if the module name indicated by
the current directory exists under F<lib/>, this module will use the
guessed package name as the default.

If this module can't find a default for C<NAME> it will ask you to specify
it manually.

=head2 VERSION

B<ExtUtils::MakeMaker> requires either the C<VERSION> or C<VERSION_FROM>
parameter.  If this module can guess the package's C<NAME>, it will attempt
to parse the C<VERSION> from it.

If this module can't find a default for C<VERSION> it will ask you to
specify it manually.

=head1 MAKE TARGETS

B<ExtUtils::MakeMaker> provides you with many useful C<make> targets. A
C<make> B<target> is the word you specify after C<make>, like C<test>
for C<make test>. Some of the more useful targets are:

=over 4

=item * all

This is the default target. When you type C<make> it is the same as
entering C<make all>. This target builds all of your code and stages it
in the C<blib> directory.

=item * test

Run your distribution's test suite.

=item * install

Copy the contents of the C<blib> directory into the appropriate
directories in your Perl installation.

=item * dist

Create a distribution tarball, ready for uploading to CPAN or sharing
with a friend.

=item * clean distclean purge

Remove the files created by C<perl Makefile.PL> and C<make>.

=item * help

Same as typing C<perldoc ExtUtils::MakeMaker>.

=back

This module modifies the behaviour of some of these targets, depending
on your requirements, and also adds the following targets to your Makefile:

=over 4

=item * cpurge

Just like purge, except that it also deletes the files originally added
by this module itself.

=item * chelp

Short cut for typing C<perldoc Module::Install>.

=item * distsign

Short cut for typing C<cpansign -s>, for B<Module::Signature> users to
sign the distribution before release.

=back

=head1 SEE ALSO

L<Module::Install>, L<CPAN::MakeMaker>, L<CPAN::MakeMaker::Philosophy>

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

Audrey Tang E<lt>autrijus@autrijus.orgE<gt>

Brian Ingerson E<lt>INGY@cpan.orgE<gt>

=head1 COPYRIGHT

Some parts copyright 2008 - 2012 Adam Kennedy.

Copyright 2002, 2003, 2004 Audrey Tang and Brian Ingerson.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
