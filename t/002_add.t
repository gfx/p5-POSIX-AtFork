#!perl
use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 6;

my $prepare = 0;
my $parent  = 0;
my $child   = 0;

POSIX::AtFork->add_to_prepare(sub{ $prepare++ }) for 1 .. 2;
POSIX::AtFork->add_to_parent( sub{ $parent++ })  for 1 .. 2;
POSIX::AtFork->add_to_child(  sub{ $child++ })   for 1 .. 2;

my $pid = dofork;

if($pid != 0) {
    is $prepare, 2, prefix . '&prepare in parent';
    is $parent,  2, prefix . '&parent in parent';
    is $child,   0, prefix . '&child in parent';
    waitpid $pid, 0;
    exit;
}
else {
    is $prepare, 2, prefix . '&prepare in child';
    is $parent,  0, prefix . '&parent in child';
    is $child,   2, prefix . '&child in child';
    exit;
}