#!perl
use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 7;

my %h;
my $prepare = 0;
my $parent  = 0;
my $child   = 0;

POSIX::AtFork->pthread_atfork(
    sub { $h{$_[0]}++; $prepare++ },
    sub { $h{$_[0]}++; $parent++; },
    sub { $h{$_[0]}++; $child++; },
);

system $^X, '-e', '0';
is $?, 0;

`$^X -e 0`;
is $?, 0;

is $prepare, 2;
is $parent,  2;
is $child,   0;

is $h{system},   2;
is $h{backtick}, 2;