#!perl
use FindBin;
use lib $FindBin::Bin;
use testlib qw( dofork prefix );
use Test::More tests => 12;

my $prepare1 = 0;
my $prepare2 = 0;
my $parent1 = 0;
my $parent2 = 0;
my $child1 = 0;
my $child2  = 0;


sub prepare1 { $prepare1++ }
sub prepare2 { $prepare2++ }

sub parent1 { $parent1++ }
sub parent2 { $parent2++ }

sub child1 { $child1++ }
sub child2 { $child2++ }

POSIX::AtFork->add_to_prepare(\&prepare1);
POSIX::AtFork->add_to_prepare(\&prepare2);
POSIX::AtFork->add_to_prepare(\&prepare1);
POSIX::AtFork->add_to_prepare(\&prepare2);
POSIX::AtFork->delete_from_prepare(\&prepare2);

POSIX::AtFork->add_to_parent(\&parent1);
POSIX::AtFork->add_to_parent(\&parent2);
POSIX::AtFork->add_to_parent(\&parent1);
POSIX::AtFork->add_to_parent(\&parent2);
POSIX::AtFork->delete_from_parent(\&parent2);

POSIX::AtFork->add_to_child(\&child1);
POSIX::AtFork->add_to_child(\&child2);
POSIX::AtFork->add_to_child(\&child1);
POSIX::AtFork->add_to_child(\&child2);
POSIX::AtFork->delete_from_child(\&child2);

my $pid = dofork;

if($pid != 0) {
    is $prepare1, 2, prefix . '&prepare1 in parent';
    is $prepare2, 0, prefix . '&prepare2 in parent';
    is $parent1,  2, prefix . '&parent1 in parent';
    is $parent2,  0, prefix . '&parent2 in parent';
    is $child1,  0, prefix . '&child1 in parent';
    is $child2,  0, prefix . '&child2 in parent';
    waitpid $pid, 0;
    exit;
}
else {
	is $prepare1, 2, prefix . '&prepare1 in child';
	is $prepare2, 0, prefix . '&prepare2 in child';
	is $parent1,  0, prefix . '&parent1 in child';
	is $parent2,  0, prefix . '&parent2 in child';
	is $child1,  2, prefix . '&child1 in child';
	is $child2,  0, prefix . '&child2 in child';

    exit;
}