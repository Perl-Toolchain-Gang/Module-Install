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
use utf8;

plan tests => 26;

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

	ok( add_file(qw(lib Foo.pm), <<'END') );
package Foo;
1;
\__END__

\=head1 NAME

Foo - Abstract

\=head1 AUTHOR

First 'Middle' Last

\=cut
END

	ok( build_dist(), 'build_dist' );
	my $file = makefile();
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content =~ /#\s*AUTHOR => q\[First 'Middle' Last\]/, 'has one author');
	my $metafile = file('META.yml');
	ok(-f $metafile);
	my $meta = Parse::CPAN::Meta::LoadFile($metafile);
	is_deeply($meta->{author}, [qq(First 'Middle' Last)]);
	ok( kill_dist(), 'kill_dist' );
}

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

	ok( add_file(qw(lib Foo.pm), <<'END') );
package Foo;
1;
\__END__

\=head1 NAME

Foo - Abstract

\=head1 AUTHOR

Olivier MenguE<eacute>

\=cut
END

	ok( build_dist(), 'build_dist' );
	my $file = makefile();
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content =~ /#\s*AUTHOR => q\[Olivier Mengu\xE9\]/, 'has one author');
	my $metafile = file('META.yml');
	ok(-f $metafile);
	my $meta = Parse::CPAN::Meta::LoadFile($metafile);
	is_deeply($meta->{author}, [qq(Olivier Mengu\xE9)]);
	ok( kill_dist(), 'kill_dist' );
}

SCOPE: {
	ok( create_dist('Foo', { 'Makefile.PL' => <<"END_DSL" }), 'create_dist' );
use inc::Module::Install 0.81;
name          'Foo';
perl_version  '5.005';
version       '0.01';
license       'perl';
author        "Olivier Mengu\xE9";
all_from      'lib/Foo.pm';
WriteAll;
END_DSL

	ok( build_dist(), 'build_dist' );
	my $file = makefile();
	ok(-f $file);
	my $content = _read($file);
	ok($content, 'file is not empty');
	ok($content =~ /#\s*AUTHOR => q\[Olivier Mengu\xE9\]/, 'has one author');
	my $metafile = file('META.yml');
	ok(-f $metafile);
	my $meta = Parse::CPAN::Meta::LoadFile($metafile);
	is_deeply($meta->{author}, [qq(Olivier Mengu\xE9)]);
	ok( kill_dist(), 'kill_dist' );
}
