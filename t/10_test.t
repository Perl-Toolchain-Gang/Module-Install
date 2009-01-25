#!/usr/bin/perl

BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 2;
use YAML::Tiny qw(LoadFile);
use File::Temp qw(tempdir);
use File::Spec qw();

my $dir = tempdir ( CLEANUP => 1 );

chdir 'test';
chdir 'A';

unlink 'META.yml';
my $out = File::Spec->catfile( $dir, 'out' );
my $err = File::Spec->catfile( $dir, 'err' );
system "$^X Makefile.PL > $out 2> $err"; # check if STD* are correct

ok(-e 'META.yml', 'META.yml created');
my $meta = LoadFile('META.yml');
is_deeply(
	[ sort @{ $meta->{no_index}->{directory} } ],
	[ qw{ eg inc t } ],
	'no_index is ok',
) or diag(
	"no_index: @{ $meta->{no_index}->{directory} }"
);

chdir '..';
chdir '..';
