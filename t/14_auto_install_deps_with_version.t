#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use t::lib::Test;
require ExtUtils::MakeMaker;
use vars qw{ $PREREQ_PM $MIN_PERL_VERSION $BUILD_REQUIRES };

plan skip_all => 'your perl is new enough to have File::Spec 3.30 in core' if $] > 5.010000;
plan skip_all => 'your File::Spec is not new enough for this test' if $File::Spec::VERSION < 3.30;

#plan tests => 15;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
test_requires 'File::Spec' => 0.6;
auto_include_deps;
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
	ok( $PREREQ_PM->{'File::Spec'} == 0.6);
	my $file_spec = File::Spec->catfile(qw(t Foo inc File Spec.pm));
	ok( !-f $file_spec, 'File::Spec is not bundled');
	ok( kill_dist('Foo'), 'kill_dist' );
}

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
author        'Someone';
license       'perl';
perl_version  '5.005';
requires_from 'lib/Foo.pm';
test_requires 'File::Spec' => 3.30;
auto_include_deps;
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
	ok( $PREREQ_PM->{'File::Spec'} == 3.30);
	my $file_spec = File::Spec->catfile(qw(t Foo inc File Spec.pm));
	ok( -f $file_spec, 'File::Spec is bundled');
	ok( kill_dist('Foo'), 'kill_dist' );
}

done_testing;