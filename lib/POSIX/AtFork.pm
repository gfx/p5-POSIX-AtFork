package POSIX::AtFork;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01_04';

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK   = qw(pthread_atfork);
our %EXPORT_TAGS = (ALL => \@EXPORT_OK);

require XSLoader;
XSLoader::load('POSIX::AtFork', $VERSION);


1;
__END__

=head1 NAME

POSIX::AtFork - Hook registrations at fork(2)

=head1 SYNOPSIS

  # POSIX interface:
  use POSIX::AtFork qw(pthread_atfork);
  
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

This module is an interface to C<pthread_atfork(3)> which registeres
handlers called before and after C<fork(2)>.

=head2 INTERFACE

See SYNOPSIS.

=head1 SEE ALSO

L<pthread_atfork(3)>.

=head1 AUTHOR

Fuji, Goro (gfx)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fuji, Goro gfx E<lt>gfuji@cpan.orgE<gt>. 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself,

=cut
