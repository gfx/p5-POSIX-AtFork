#!perl
use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 6;
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
local $!;
eval {
	$pid = dofork;
	# If we somehow forked, don't break the test output.
	exit if defined($pid) && $pid == 0;
};
ok($@ =~ qr/foo/, prefix . "Dies with expected error");
ok(! $!, prefix . "OS_ERROR not set");
is($$, getpid(), prefix . "can read pid");
is(getppid(), $oldppid, prefix . "child is created as expected");
# Check standard return behavior, since we're messing about in calls where perl thinks
# it should not be possible to do so.
ok(! defined $pid, prefix . "return value is not defined");
is($parent, undef, prefix . "post-fork parent sub does not run");