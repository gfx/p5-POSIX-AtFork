#!perl
use strict;
use warnings;
use POSIX::AtFork qw(:all);
use Test::More tests => 15;
use constant SUB => sub {};
sub testboth {
	my ( $sub, @args ) = @_;
	local $@;
	eval { POSIX::AtFork->$sub(@args) };
	ok(!$@, "can call $sub as a class method $@");
	my $func = "POSIX::AtFork::$sub";
	eval { $func = \&{$func}; $func->(@args) };
	ok(!$@, "can call $sub as a function $@");

	return;
}
local $@;
eval { pthread_atfork(SUB, SUB, SUB) };
ok(!$@, ":all imports pthread_atfork");

testboth("pthread_atfork", SUB, SUB, SUB);
testboth("add_to_prepare", SUB);
testboth("add_to_parent", SUB);
testboth("add_to_child", SUB);
testboth("delete_from_prepare", SUB);
testboth("delete_from_parent", SUB);
testboth("delete_from_child", SUB);
# my $prepare = 0;
# my $parent  = 0;
# my $child   = 0;

# my $parent_pid = $$;

# POSIX::AtFork::pthread_atfork(
#     sub { $prepare++ },
#     sub { $parent++; },
#     sub { $child++; },
# );

# my $pid = Test::SharedFork->fork;
# die "Failed to fork: $!" if not defined $pid;

# if($pid != 0) {
#     is $$, $parent_pid;

#     is $prepare, 1, '&prepare in parent';
#     is $parent,  1, '&parent in parent';
#     is $child,   0, '&child in parent';
#     waitpid $pid, 0;
#     exit;
# }
# else {
#     is $prepare, 1, '&prepare in child';
#     is $parent,  0, '&parent in child';
#     is $child,   1, '&child in child';
#     exit;
# }