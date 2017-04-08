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
add_to_child(sub { $didprepare = 0; });

# Calls warn. In a separate sub for test mocking.
sub _warn { warn @_; }

sub _run_callbacks ($$) {
  my ( $op, $type ) = @_;

  foreach my $array (values(%{$callbacks{$type}})) {
    foreach my $cb (@$array) {
      # die/warn in callbacks can violate the contracts of an error mode:
      # e.g. a __WARN__ handler might die even if death is not allowed.
      local $SIG{__DIE__};
      local $SIG{__WARN__};
      if ( $cb->{onerror} eq "die" ) {
        $cb->{code}->($op);
      } else {
        local $@;
        eval {
          $cb->{code}->($op);
        };
        if ( $@ && $cb->{onerror} eq "warn" ) {
          _warn("Callback for pthread_atfork() died (ignored): $@");
        }
      }
    }
  }
}

sub _manip_callbacks {
  my $args = shift;
  my $type = delete $args->{type};
  my $name = delete $args->{name};
  if ( ! exists($callbacks{$type}) ) {
    die "event type '$args->{type}' not recognized";
  }

  if ( delete $args->{remove} ) {
    return @{delete($callbacks{$type}->{$name}) || []};
  } else {
    return push(@{$callbacks{$type}->{$name}}, $args);
  }
}

# Parameters:
# code (required): coderef to run.
# onerror: die, warn, or silent.
# name: key for use in delete; defaults to stringy version of coderef.
sub _getargs {
  shift if $_[0] eq __PACKAGE__;
  my %args;
  if ( scalar(@_) == 1 ) {
    if ( ref($_[0]) eq "CODE" ) {
      %args = (
        code => $_[0],
        onerror => "warn",
      );
    } elsif ( ref($_[0]) eq "HASH" ) {
      %args = %{$_[0]};
    } else {
      die "Arguments must be a code or hash reference";
    }
  } else {
    %args = @_;
  }

  die "'code' attribute is required" unless $args{code};
  $args{name} ||= "$args{code}";
  $args{onerror} ||= "silent";
  if ( ! grep { $args{onerror} } qw( warn die silent ) ) {
    die "'onerror' must be one of warn, die, or silent; got '$args{onerror}' instead";
  }
  # Assertions go here
  return %args;
}

sub pthread_atfork {
  shift if $_[0] eq __PACKAGE__;
  add_to_prepare(shift);
  add_to_parent(shift);
  add_to_child(shift);
}

sub add_to_prepare { return _manip_callbacks({ _getargs(@_), type => PREPARE, remove => 0 }); }
sub add_to_parent { return _manip_callbacks({ _getargs(@_), type => PARENT, remove => 0 }); }
sub add_to_child { return _manip_callbacks({ _getargs(@_), type => CHILD, remove => 0 }); }
sub delete_from_prepare { return _manip_callbacks({_getargs(@_), type => PREPARE, remove => 1 }); }
sub delete_from_parent { return _manip_callbacks({_getargs(@_), type => PARENT, remove => 1 }); }
sub delete_from_child { return _manip_callbacks({_getargs(@_), type => CHILD, remove => 1 }); }

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
