#!perl
use strict;
use warnings;
no warnings "redefine";

use Test::More tests => 9;
use Test::SharedFork;
use POSIX::AtFork qw(:all);
use POSIX qw(getpid);

POSIX::AtFork->add_to_prepare(sub { die "foo" });

my $oldpid = $$;
my $pid;
my @warnings;
local $@;
eval {
	# Use a mock since we can't use $SIG{__WARN__}.
	local *POSIX::AtFork::_warn = sub { push(@warnings, @_); };
	$pid = fork;
	die "Failed to fork: $!" if not defined $pid;
};
ok(! $@, '$@ not set');
ok(! $!, "OS_ERROR not set");
if ( $pid == 0 ) {
	is($$, getpid(), "Child PID is accurate");
	ok($$ != $oldpid, "Child is not parent");
	is(getppid(), $oldpid, "Child exists");
	exit;
} else {
	is($$, getpid(), "Parent PID is accurate");
	is($$, $oldpid, "Parent PID does not change");
	waitpid $pid, 0;
	exit;
}