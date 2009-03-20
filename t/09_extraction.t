#!/usr/bin/perl -w
use strict;

BEGIN {
        $|  = 1;
        $^W = 1;
}

use Test::More tests => 5;
require_ok( 'Module::Install::Metadata' );
{
my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test>');
is_deeply(
	\@links,
	[ 'http://rt.cpan.org/test' ],
	'1 bugtracker extracted',
) or diag(
	"bugtrackers: @links"
);

}

{
my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test1> L<http://rt.cpan.org/test1>');
is_deeply(
	\@links,
	[ 'http://rt.cpan.org/test1' ],
	'1 bugtracker extracted (2 links)',
) or diag(
	"bugtrackers: @links"
);

}

{
my @links=Module::Install::Metadata::_extract_bugtracker('L<http://rt.cpan.org/test1> L<http://rt.cpan.org/test2>');
is_deeply(
	[ sort @links ],
	[ 'http://rt.cpan.org/test1', 'http://rt.cpan.org/test2' ],
	'2 bugtrackers extracted',
) or diag(
	"bugtrackers: @links"
);

}

{
my @links=Module::Install::Metadata::_extract_bugtracker('L<http://search.cpan.org/test1>');
is_deeply(
	\@links,
	[ ],
	'0 bugtrackers extracted',
) or diag(
	"bugtrackers: @links"
);

}
