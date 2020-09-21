use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}
use Test::More;

my @existing_versions = ( qw(5.005 5.01 5.010 5.0100 5.01000 5.010000 5.10.0
    5.010.000) );
my @missing_versions = ( qw(5.005002 5.5.2) );
plan tests => 1 + @existing_versions + @missing_versions;

require_ok( 'Module::Install::Admin::ScanDeps' );
my $m = Module::Install::Admin::ScanDeps->new;

for my $version (@existing_versions) {
    eval { $m->scan_dependencies(q{Carp}, $version, q{0}) };
	ok(!$@, "scan_dependencies() can query core modules for $version Perl");
}
for my $version (@missing_versions) {
    eval { $m->scan_dependencies(q{Carp}, $version, q{0}) };
	ok($@, "scan_dependencies() cannot query core modules for $version Perl");
}
