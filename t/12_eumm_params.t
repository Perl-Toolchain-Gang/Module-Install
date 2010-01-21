#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 11;
use File::Spec;
use t::lib::Test;
require ExtUtils::MakeMaker;
use vars qw{ $PREREQ_PM, $MIN_PERL_VERSION, $BUILD_REQUIRES };

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

# Regular build
SCOPE: {
	#ok( create_dist('Foo'), 'create_dist' );
        ok( create_dist( 'Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
requires      'File::Spec' => '0.79';
WriteAll;
END_DSL

	ok( run_makefile_pl('Foo',(run_params=>['PREREQ_PRINT >test'])),  'build_dist'  );
	my $file=File::Spec->catfile(qw(t Foo test));
	ok( -f $file);
	my $content=_read($file);
	ok( $content,'file is not empty');
	ok( $content =~ s/^.*\$PREREQ_PM = \{/\$PREREQ_PM = {/s,'PREREQ_PM found');
	eval ($content);
	ok( !$@,'correct content');
	ok( exists $PREREQ_PM->{'File::Spec'});
	if ( eval($ExtUtils::MakeMaker::VERSION) < 6.55_03 ) {
		ok( exists $PREREQ_PM->{'ExtUtils::MakeMaker'});
		ok( !exists $BUILD_REQUIRES->{'ExtUtils::MakeMaker'});
		ok (1);
	} else { #best to check both because user can have any version
		ok( exists $BUILD_REQUIRES->{'ExtUtils::MakeMaker'});
		ok( !exists $PREREQ_PM->{'ExtUtils::MakeMaker'});
		is( $MIN_PERL_VERSION, '5.005' , 'correct Perl version');
	}
	ok( kill_dist('Foo'), 'kill_dist' );
}

