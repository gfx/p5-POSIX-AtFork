use strict;
use warnings;
use ExtUtils::MakeMaker qw( WriteMakefile );

WriteMakefile(
    NAME            => 'POSIX::AtFork',
    VERSION_FROM    => 'lib/POSIX/AtFork.pm',
    LIBS => [qw(-lpthread -lc -lgcc -lc)],
    TEST_REQUIRES => {
    	"Test::SharedFork" => 0,
    	"Test::More" => 0,
    },
    CCFLAGS => "-Wall -Wextra -Wdeclaration-after-statement -Wno-comment",
    # CONFIGURE => sub {
    # 	require Devel::PPPort;
    # 	Devel::PPPort::WriteFile("ppport.h");
    # 	return {};
    # },
    # clean => {FILES => "ppport.h"},
    # DEFINE => "-DUSE_PPPORT",
    # CONFIGURE_REQUIRES => {
    # 	"Devel::PPPort" => 0,
    # 	},
    # BUILD_REQUIRES => {
    # 	"Devel::PPPort" => 0,
    # },
);