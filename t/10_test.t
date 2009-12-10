#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 7;
use Config                ();
use File::Spec::Functions ':ALL';
use File::Temp            ();
use YAML::Tiny            ();
use Symbol;

chdir( catdir('test', 'A') );
unlink( 'META.yml', 'MYMETA.yml' );

my $dir = File::Temp::tempdir( CLEANUP => 1 );
my $out = File::Spec->catfile( $dir, 'out'  );
my $err = File::Spec->catfile( $dir, 'err'  );

system("$^X Makefile.PL > $out 2> $err");

#Test META.yml

ok( -e 'META.yml', 'META.yml created' );
my $meta = YAML::Tiny::LoadFile('META.yml');

is_deeply(
	[ sort @{ $meta->{no_index}->{directory} } ],
	[ qw{ eg inc t } ],
	'no_index is ok',
) or diag(
	"no_index: @{ $meta->{no_index}->{directory} }"
);
is_deeply(
	$meta->{keywords},
	[ 'kw1','kw 2','kw3'],
	'no_index is ok',
) or diag(
	"no_index: @{ $meta->{no_index}->{directory} }"
);
is($meta->{license},'apache','license');
is($meta->{resources}->{license},'http://apache.org/licenses/LICENSE-2.0','license URL');

#Test Makefile
ok( -e 'Makefile', 'Makefile created' );

my $mf = gensym;
open $mf,'<Makefile';
my @lines=<$mf>;
my ($line )=grep {$_=~/^#\s+PREREQ_PM/} @lines;
ok($line,'PREREQ_PM found');

chdir( catdir( updir(), updir() ) );
