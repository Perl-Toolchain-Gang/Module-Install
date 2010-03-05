#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More;
use File::Spec;
use Parse::CPAN::Meta;
use t::lib::Test;

#plan tests => 32;

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
perl_version  '5.005';
version       '0.01';
license       'perl';
all_from      'lib/Foo.pm';
WriteAll;
END_DSL

	ok( add_file('Foo', 'lib/Foo.pm', <<'END') );
package Foo;
1;
\__END__

\=head1 NAME

Foo - Abstract

\=head1 AUTHOR

First 'Middle' Last

\=cut
END

	ok( build_dist('Foo'), 'build_dist' );
	my $file = File::Spec->catfile(qw(t Foo Makefile));
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content =~ /#\s*AUTHOR => q\[First 'Middle' Last\]/, 'has one author');
	my $metafile = File::Spec->catfile(qw(t Foo META.yml));
	ok(-f $metafile);
	my $meta = Parse::CPAN::Meta::LoadFile($metafile);
	is_deeply($meta->{author}, [qq(First 'Middle' Last)]);
	ok( kill_dist('Foo'), 'kill_dist' );
}

done_testing;
