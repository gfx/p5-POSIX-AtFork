package testlib;

use strict;
use warnings;
use English qw( -no-match-vars );
use POSIX qw( getpid );
use POSIX::AtFork;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( dofork prefix );

my $originalpid = $PROCESS_ID;

sub prefix() {
	my $current = $originalpid == $PROCESS_ID ? "parent" : $originalpid == getppid() ? "child" : "unknown";
	return sprintf(
		"[ current: %s (%d) ] ",
		$current,
		$PROCESS_ID,
	);
}

sub import {
	$OUTPUT_AUTOFLUSH = 1;
	__PACKAGE__->export_to_level(1, @_);
	strict->import;
	warnings->import;
	warnings->unimport('uninitialized');
	require Test::SharedFork;
	Test::SharedFork->import;
	English->export_to_level(1, $_[0], @English::MINIMAL_EXPORT);
	POSIX::AtFork->import;
}

sub dofork {
	$OS_ERROR = undef;
	my $pid = fork();
	warn prefix . sprintf("unexpected errno: %d (%s)\n", int($OS_ERROR), $OS_ERROR) if $OS_ERROR;
	die "couldn't read process id variable" unless $PROCESS_ID;
	die "couldn't getpid()" unless getpid();
	die "pid reader mismatch: $PROCESS_ID vs " . getpid() if $PROCESS_ID != getpid();
	die "Failed to fork: $!" if not defined $pid;
	return $pid;
}

1;