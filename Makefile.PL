use strict;
use warnings;
use ExtUtils::MakeMaker qw( WriteMakefile );

# "Parse" version, strip out e.g. 5.5_05 post-underscore bits.
my @v = map { my @b = split(/[^0-9]/, $_); shift(@b); } split(/[.]/, $ExtUtils::MakeMaker::VERSION || "1.0");
$v[1] = substr($v[1], 0, 2) if length($v[1]) > 2;
# TEST_REQUIRES only added in 6.64.
my $testrequireskey = $v[0] < 6 || ( $v[0] == 6 && $v[1] < 64 ) ? "BUILD_REQUIRES" : "TEST_REQUIRES";

WriteMakefile(
    NAME => 'POSIX::AtFork',
    VERSION_FROM => 'lib/POSIX/AtFork.pm',
    LIBS => [qw(-lpthread)],
    $testrequireskey => {
        "Test::SharedFork" => 0,
        "Test::SharedFork::Scalar" => 0,
        "Test::More" => 0,
    },
    CCFLAGS => "-Wall -Wextra -Wdeclaration-after-statement -Wno-comment",
    dynamic_lib => {
        # I think this is necessary to keep our use of __dso_handle from colliding
        # with the one supplied by the crt* libs or equivalent. I'm honestly not
        # sure why there are collisions, but the combination of this flag and the
        # redeclaration of __dso_handle in the XS prevents hangs on Linux when
        # callbacks die(). If the handle's defined as an "extern", non-GCC compilers
        # generate a broken binary; guarding it in an ifdef doesn't work (since it
        # isn't a define), so this flag seems to access the best of both worlds.
        # Patches welcome.
        OTHERLDFLAGS => "-nostartfiles"
    },
);
