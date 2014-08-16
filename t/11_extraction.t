#!perl

use strict;
BEGIN {
        $|  = 1;
        $^W = 1;
}

use Test::More tests => 26;

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
	my $l=Module::Install::Metadata::_extract_license("=head1 Copyright\nunder the same terms as the perl 5 programming language system itself\n=cut\n");
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
        my $text="=head1 LICENSE

This is free software, you may use it and distribute it under
the same terms as the perl 5 programming language system itself.

=head1 SEE ALSO

test

=cut
";
	my $l=Module::Install::Metadata::_extract_license($text);
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
        my $text="=head1 COPYRIGHTS

This module is distributed under the same terms as the perl 5 programming language system itself.

=cut
";
	my $l=Module::Install::Metadata::_extract_license($text);
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 COPYRIGHT\nThe GNU Lesser General Public License, Version 2.1, February 1999\n=cut\n");
		is($l, 'lgpl', 'LGPL license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 COPYRIGHT\nThe GNU Lesser General Public License, Version 3, June 2007\n=cut\n");
		is($l, 'lgpl', 'LGPL license detected',
	);
}

SCOPE: {
        my $text=<<'EOT';
=head1 COPYRIGHT AND LICENCE

... is free software; you can redistribute it and/or modify it under
the same terms as the perl 5 programming language system itself, that is to say, under the terms of either:

=over 4

=item *

The GNU General Public License as published by the Free Software Foundation;
either version 2, or (at your option) any later version, or

=item *

The "Artistic License" which comes with Perl.

=back

=cut
EOT
	my $l=Module::Install::Metadata::_extract_license($text);
		is($l, 'perl', 'Perl license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENSE\nThe Artistic License 1.0\n=cut\n");
		is($l, 'artistic', 'Artistic license detected',
	);
}


SCOPE: {
        my $text=<<'EOT';
=head1 COPYRIGHT AND LICENCE

Copyright (C) 2010

This library is free software; you can redistribute it and/or modify it under the terms of The Artistic License 2.0 (GPL Compatible) For details, see the full text of the license at http://opensource.org/licenses/artistic-license-2.0.php.

=cut
EOT
	my $l=Module::Install::Metadata::_extract_license($text);
		is($l, 'artistic_2', 'Artistic license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENCE\nThe (three-clause) BSD License\n=cut\n");
		is($l, 'bsd', 'BSD license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENCE\nThe GNU General Public License, Version 1, February 1989\n=cut\n");
		is($l, 'gpl', 'GNU license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENsE\nThe GNU General Public License, Version 2, June 1991\n=cut\n");
		is($l, 'gpl', 'GNU license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENCE\nThe GNU General Public License, Version 3, June 2007\n=cut\n");
		is($l, 'gpl', 'GNU license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENCE\nThe MIT (X11) License\n=cut\n");
		is($l, 'mit', 'MIT license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENCE\nThe Mozilla Public License 1.0\n=cut\n");
		is($l, 'mozilla', 'Mozilla license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 LICENSE\nThe Mozilla Public License 1.1\n=cut\n");
		is($l, 'mozilla', 'Mozilla license detected',
	);
}

SCOPE: {
	my $l=Module::Install::Metadata::_extract_license("=head1 Copyright\nMozilla Public License Version 2.0\n=cut\n");
		is($l, 'mozilla', 'Mozilla license detected',
	);
}


SCOPE: {
	my $version=Module::Install::Metadata::_extract_perl_version("use 5.10.0;");
		is($version, '5.10.0', 'perl 5.10.0 detected',
	);
}

SCOPE: {
	my $version=Module::Install::Metadata::_extract_perl_version("   use 5.010;");
		is($version, '5.010', 'perl 5.10.0 detected',
	);
}

SCOPE: {
	my $version=Module::Install::Metadata::_extract_perl_version("use strict;");
		is($version, undef, 'no perl prereq',
	);
}
