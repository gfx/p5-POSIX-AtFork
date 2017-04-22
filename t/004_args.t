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
