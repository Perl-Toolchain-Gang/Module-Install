#!/usr/bin/perl

use strict;
BEGIN {
        $|  = 1;
        $^W = 1;
}

use Test::More tests => 12;

require_ok( 'Module::Install::Metadata' );

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test>');
	is_deeply(
		\@links,
		[ 'http://rt.cpan.org/test' ],
		'1 bugtracker extracted',
	) or diag(
		"bugtrackers: @links"
	);
}

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test1> L<http://rt.cpan.org/test1>');
	is_deeply(
		\@links,
		[ 'http://rt.cpan.org/test1' ],
		'1 bugtracker extracted (2 links)',
	) or diag(
		"bugtrackers: @links"
	);
}

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test1> L<http://rt.cpan.org/test2>');
	is_deeply(
		[ sort @links ],
		[ 'http://rt.cpan.org/test1', 'http://rt.cpan.org/test2' ],
		'2 bugtrackers extracted',
	) or diag(
		"bugtrackers: @links"
	);
}

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://search.cpan.org/test1>');
	is_deeply(
		\@links,
		[ ],
		'0 bugtrackers extracted',
	) or diag(
		"bugtrackers: @links"
	);
}

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://github.com/marcusramberg/mojomojo/issues>');
	is_deeply(
		\@links,
		[ 'http://github.com/marcusramberg/mojomojo/issues' ],
		'1 bugtracker (github.com) extracted',
	) or diag(
		"bugtrackers: @links"
	);
}

SCOPE: {
	my @links=Module::Install::Metadata::_extract_bugtracker('L<http://code.google.com/p/www-mechanize/issues/list>');
	is_deeply(
		\@links,
		[ 'http://code.google.com/p/www-mechanize/issues/list' ],
		'1 bugtracker (code.google.com) extracted',
	) or diag(
		"bugtrackers: @links"
	);
}




SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 copyright\nunder the same terms as the perl programming language\n=cut\n");
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
        my $text="=head1 LICENSE

This is free software, you may use it and distribute it under
the same terms as Perl itself.

=head1 SEE ALSO

test

=cut
";
	my $l=Module::Install::Metadata::_extract_license($text);
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 copyright\nAs LGPL license\n=cut\n");
		is($l, 'lgpl', 'LGPL detected',
	);
}


SCOPE: {
	my $version=Module::Install::Metadata::_extract_perl_version("use 5.10.0;");
		is($version, '5.10.0', 'perl 5.10.0 detected',
	);
}

SCOPE: {
	my $version=Module::Install::Metadata::_extract_perl_version("use strict;");
		is($version, undef, 'no perl prereq',
	);
}
