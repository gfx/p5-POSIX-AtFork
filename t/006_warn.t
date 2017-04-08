#!perl

use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 11;
no warnings "redefine";

POSIX::AtFork->add_to_prepare(sub { die "foo" });

my $oldpid = $$;
my $pid;
my @warnings;
local $@;
local $!;
eval {
	# Use a mock since we can't use $SIG{__WARN__}.
	local *POSIX::AtFork::_warn = sub { push(@warnings, @_); };
	$pid = dofork;
};
ok(! $@, prefix . '$@ not set');
ok(! $!, prefix . "OS_ERROR not set");
is(scalar(@warnings), 1, prefix . "Only one warning logged");
is(index($warnings[0], "Callback for pthread_atfork() died (ignored): foo"), 0, prefix . "Correct warning logged");
if ( $pid == 0 ) {
	ok($$ != $oldpid, prefix . "Child is not parent");
	is(getppid(), $oldpid, prefix . "Child exists");
	exit;
} else {
	is($$, $oldpid, "prefix . Parent PID does not change");
	waitpid $pid, 0;
	exit;
}