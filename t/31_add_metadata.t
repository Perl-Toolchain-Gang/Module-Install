#!/usr/bin/perl

use strict;
BEGIN {
    $|  = 1;
    $^W = 1;
}


use Test::More;
use t::lib::Test;
use YAML::Tiny;

plan tests => 6;

SCOPE: {
    no utf8;
    ok( create_dist('Foo', { 'Makefile.PL' => <<'END_DSL' }), 'create_dist Foo');
use utf8;
use inc::Module::Install;
name          'Foo';
perl_version  '5.005';
all_from      'lib/Foo.pm';
add_metadata  'x_foo' => 'bar';
add_metadata  'x_contributors' => ['Alberto Simões <ambs@cpan.org>'];
WriteAll;
END_DSL

    ok( build_dist(), 'build_dist' );
    my $file = file('META.yml');
    ok( -f $file);
    my $yaml = YAML::Tiny::LoadFile($file);
    ok( $yaml->{x_foo} && $yaml->{x_foo} eq 'bar' );
    
    use utf8;
    my $test_string = 'Alberto Simões <ambs@cpan.org>';
    ok( ($yaml->{x_contributors}[0] || "") eq $test_string);
    ok( kill_dist(), 'kill_dist' );
}
