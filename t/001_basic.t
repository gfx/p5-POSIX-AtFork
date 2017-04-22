#!perl

use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 6;

my $prepare = 0;
my $parent  = 0;
my $child   = 0;

POSIX::AtFork->pthread_atfork(
    sub { $prepare++ },
    sub { $parent++ },
    sub { $child++ },
);

my $pid = dofork;

if($pid != 0) {
    is $prepare, 1, prefix . '&prepare in parent';
    is $parent,  1, prefix . '&parent in parent';
    is $child,   0, prefix . '&child in parent';
    waitpid $pid, 0;
    exit;
}
else {
    is $prepare, 1, prefix . '&prepare in child';
    is $parent,  0, prefix . '&parent in child';
    is $child,   1, prefix . '&child in child';
    exit;
}