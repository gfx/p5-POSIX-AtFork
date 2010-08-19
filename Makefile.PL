use strict;
use inc::Module::Install;
use Module::Install::XSUtil;

all_from 'lib/POSIX/AtFork.pm';

cc_warnings;
use_ppport;

test_requires 'Test::More' => 0.88; # done_testing()

tests_recursive;

WriteAll(check_nmake => 0);
