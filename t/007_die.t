#!perl
use strict;
use warnings;

use Test::More tests => 6;
use POSIX::AtFork qw(:all);
use POSIX qw(getpid);

my $parent;
POSIX::AtFork->add_to_parent({
	code => sub { $parent++; },
	onerror => "die",
});
POSIX::AtFork->add_to_prepare({
	code => sub { die "foo"; },
	onerror => "die",
});

my $oldpid = $$;
my $oldppid = getppid();
my $pid;

local $@;
eval {
	$pid = fork;
	# If we somehow forked, don't break the test output.
	exit if defined($pid) && $pid == 0;
};
ok($@ =~ qr/foo/, "Dies with expected error");
ok(! $!, "OS_ERROR not set");
is($$, getpid());
is(getppid(), $oldppid);
# Check standard return behavior, since we're messing about in calls where perl thinks
# it should not be possible to do so.
ok(! defined $pid, "Pid is not defined");
is($parent, undef, "Post-fork parent sub does not run");