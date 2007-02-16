if ( !$ENV{TEST_POD} ) {
    print "1..0 # Skip set TEST_POD to enable this test\n";
    exit;
}

eval "
use Test::More;
use Test::Pod 1.14
";

if ( $@ ) {
    print "1..0 # Skip Test::More and Test::Pod 1.14 required - $@\n";
    exit;
}

all_pod_files_ok();
