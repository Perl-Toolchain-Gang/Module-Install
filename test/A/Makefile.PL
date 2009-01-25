use inc::Module::Install 0.78;

name          'A';
license       'perl';
author        'Foo Bar <foo@bar.com>';
all_from      'lib/A.pm';
requires      'perl'       => '5.008000';
test_requires 'Test::More' => '0.47';
no_index      'directory'  => qw{ t xt share inc };
install_share 'eg';

WriteAll;
