package Module::Install::DSL;

=pod

=head1 NAME

=head1 SYNOPSIS

  use inc::Module::Install 0.78;
  use Module::Install::DSL;
  
  all_from       lib/ADAMK/Repository.pm
  requires       File::Spec            3.29
  requires       File::pushd           1.00
  requires       File::Find::Rule      0.30
  requires       File::Find::Rule::VCS 1.05
  requires       File::Flat            0
  requires       File::Remove          1.42
  requires       IPC::Run3             0.034
  requires       Object::Tiny          1.06
  requires       Params::Util          0.35
  requires       CPAN::Version         5.5
  test_requires  Test::More            0.86
  test_requires  Test::Script          1.03
  install_script adamk
  
  requires_external_bin svn

=head1 DESCRIPTION

One of the primary design goals of L<Module::Install> is to simplify
the creation of F<Makefile.PL> scripts.

Part of this involves the gradual reduction of any and all superflous
characters, with the ultimate goal of requiring no non-critical
information in the file.

L<Module::Install::DSL> is a simple B<Domain Specific Language> based
on the already-lightweight L<Module::Install> command syntax.

The DSL takes one command on each line, and then wraps the command
(and its parameters) with the normal quotes and semi-colons etc to
turn it into Perl code.

=cut

use strict;
use vars qw{$VERSION $ISCORE};
BEGIN {
	$VERSION = '0.78';
	$ISCORE  = 1;
}

sub import {
	# Read in the rest of the Makefile.PL
	open 0 or die "Couldn't open $0: $!";
	my $dsl;
	SCOPE: {
		local $/ = undef;
		$dsl = join "", <0>;
	}

	# Change inc::Module::Install::DSL to the regular one.
	# Remove anything before the use inc::... line.
	$dsl =~ s/.*?^\s*use\s+Module::Install::DSL(\b[^;]*);\s*\n//sm;

	# Convert the basic syntax to code
	my $code = "package main;\n\n"
	         . dsl2code($dsl)
	         . "\n\nWriteAll();\n";

	# Execute the script
	eval $code;
	if ( $@ ) {
		# Eek
		print STDERR "Failed to execute the generated code";
	}
	exit(0);
}

sub dsl2code {
	my $dsl = shift;

	# Split into lines and strip blanks
	my @lines = grep { /\S/ } split /[\012\015]+/, $dsl;

	# Each line represents one command
	my @code = ();
	foreach my $line ( @lines ) {
		# Split the lines into tokens
		my @tokens = split /\s+/, $line;

		# The first word is the command
		my $command = shift @tokens;
		my @params  = ();
		my @suffix  = ();
		while ( @tokens ) {
			my $token = shift @tokens;
			if ( $token eq 'if' or $token eq 'unless' ) {
				# This is the beginning of a suffix
				push @suffix, $token;
				push @suffix, @tokens;
				last;
			} else {
				# Convert to a string
				$token =~ s/([\\\'])/\\$1/g;
				push @params, "'$token'";
			}	
		};

		# Merge to create the final line of code
		@tokens = ( $command, @params ? join( ', ', @params ) : (), @suffix );
		push @code, join( ' ', @tokens ) . ";\n";
	}

	# Join into the complete code block
	return join( '', @code );
}

1;

=pod

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Module-Install>

For other issues contact the author.

=head1 AUTHORS

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2008 - 2009 Adam Kennedy.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
