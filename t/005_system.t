#!perl
use strict;
use warnings;
use Test::More tests => 5;
use Test::SharedFork;
use POSIX::AtFork qw(:ALL);
use POSIX qw(getpid);

my $prepare = 0;
my $parent  = 0;
my $child   = 0;

pthread_atfork(
    sub { $prepare++ },
    sub { $parent++; },
    sub { $child++; },
);

system $^X, '-e', '0';
is $?, 0;

`$^X -e 0`;
is $?, 0;

is $prepare, 0;
is $parent,  0;
is $child,   0;

