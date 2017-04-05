package POSIX::AtFork;

use 5.008001;

use strict;
use warnings;

our $VERSION = '0.02';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK   = qw(pthread_atfork);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

require XSLoader;
XSLoader::load('POSIX::AtFork', $VERSION);

use constant {
  PARENT => "parent",
  PREPARE => "prepare",
  CHILD => "child",
};

my $oldpid = $$;
my $didprepare = 0;
my %callbacks = (
  PARENT() => {},
  PREPARE() => {},
  CHILD() => {},
);

add_to_parent(sub { $didprepare = 0; });
add_to_child(sub { $didprepare = 0; }); # TODO only non-vforkish

sub _run_callbacks ($) {

  my $type = $oldpid == $$ ? $didprepare++ ? PARENT : PREPARE : CHILD;

  $oldpid = $$;

  foreach my $array (values(%{$callbacks{$type}})) {
    foreach my $cb (@$array) {
      local $@;
      eval {
        $cb->(@_);
      };
      warn "Callback for pthread_atfork() died (ignored): $@" if $@;
    }
  }
}

sub _manip_callbacks {
  shift if $_[0] eq __PACKAGE__;
  my ( $cb, $type, $remove ) = @_;
  if ( $remove ) {
    return @{delete $callbacks{$type}->{$cb}};
  } else {
    return push(@{$callbacks{$type}->{$cb}}, $cb);
  }
}

sub pthread_atfork {
  shift if $_[0] eq __PACKAGE__;
  add_to_prepare(shift);
  add_to_parent(shift);
  add_to_child(shift);
}

sub add_to_prepare { push(@_, PREPARE); goto &_manip_callbacks; }
sub add_to_parent { push(@_, PARENT); goto &_manip_callbacks; }
sub add_to_child { push(@_, CHILD); goto &_manip_callbacks; }
sub delete_from_prepare { push(@_, PREPARE, 1); goto &_manip_callbacks; }
sub delete_from_parent { push(@_, PARENT, 1); goto &_manip_callbacks; }
sub delete_from_child { push(@_, CHILD, 1); goto &_manip_callbacks; }

# ZBTODO weakref callback support
# ZBTODO clear_all_*
# ZBTODO fatal or non: prepare defaults to fatal??
# ZBTODO even for nonfatal, keep first-encountered $@ around and set it like KEEPERR.
# ZBTODO test what happens if fork itself fails; document that prepare hooks still ran.
# ZBTODO support "remove one reference to this sub"
# ZBTODO support blocks to execute
# ZBTODO fall back to __register_atfork?
# ZBTODO check return codes.
# ZBTODO update system_t to opname_t, test for more stuffs (basic fork, c forkers?)

1;
__END__

=head1 NAME

POSIX::AtFork - Hook registrations at fork(2)

=head1 SYNOPSIS

  # POSIX interface:
  use POSIX::AtFork qw(:all);
  
  pthread_atfork(\&prepare, \&parent, \&child);

  # or per-hook interfaces:
  POSIX::AtFork->add_to_prepare(\&prepare);
  POSIX::AtFork->add_to_parent(\&parent);
  POSIX::AtFork->add_to_child(\&child);

  # registered callbacks can be removed
  POSIX::AtFork->delete_from_prepare(\&prepare);
  POSIX::AtFork->delete_from_parent( \&parent);
  POSIX::AtFork->delete_from_child(  \&child);

=head1 DESCRIPTION

This module is an interface to C<pthread_atfork(3)>, which registeres
handlers called before and after C<fork(2)>.

=head1 INTERFACE

=head2 pthread_atfork(\&prepare, \&parent, \&child)

Registeres hooks called before C<fork()> (I<&prepare>) and after
(I<&parent> for the parent, I<&child> for the child).

All callbacks are called with the current opname, namely C<fork>,
C<system>, C<backtick>, and etc.

This exportable function is an interface to C<pthread_atfork(3)>.

=head2 POSIX::AtFork->add_to_prepare(\&hook)

The same as C<pthread_atfork(\&hook, undef, undef)>.

=head2 POSIX::AtFork->add_to_parent(\&hook)

The same as C<pthread_atfork(undef, \&hook, undef)>.

=head2 POSIX::Atfork->add_to_child(\&hook)

The same as C<pthread_atfork(undef, undef, \&hook)>.

=head2 POSIX::AtFork->delete_from_prepare(\&hook)

Deletes I<&hook> from the C<prepare> hook list.

=head2 POSIX::AtFork->delete_from_parent(\&hook)

Deletes I<&hook> from the C<parent> hook list.

=head2 POSIX::AtFork->delete_from_child(\&hook)

Deletes I<&hook> from the C<child> hook list.

=head1 SEE ALSO

L<pthread_atfork(3)>

L<fork(2)>

=head1 AUTHOR

Fuji, Goro (gfx)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fuji, Goro gfx E<lt>gfuji@cpan.orgE<gt>. 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself,

=cut
