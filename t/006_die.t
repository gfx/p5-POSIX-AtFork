#!perl
use strict;
use warnings;

use Test::More tests => 5;
use Test::SharedFork;
use POSIX::AtFork qw(:all);
use POSIX qw(getpid);
POSIX::AtFork->add_to_prepare(sub { die "foo" });

my $oldpid = $$;
my $oldppid = getppid();
my $pid;

local $@;
eval { $pid = fork; };
ok($@ =~ qr/foo/, "Dies with expected error");
ok(! $!, "OS_ERROR not set");
is($$, getpid());
is(getppid(), $oldppid);
# Check standard return behavior, since we're messing about in calls where perl thinks
# it should not be possible to do so.
ok(! defined $pid, "Pid is not defined");

