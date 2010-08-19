package POSIX::AtFork;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(pthread_atfork);

require XSLoader;
XSLoader::load('POSIX::AtFork', $VERSION);


1;
__END__

=head1 NAME

POSIX::AtFork - Perl extension for blah blah blah

=head1 SYNOPSIS

  use POSIX::AtFork;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for POSIX::AtFork, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

L<pthread_atfork(3)>.

=head1 AUTHOR

Fuji, Goro (gfx)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Fuji, Goro gfx E<lt>gfuji@cpan.orgE<gt>. 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself,

=cut
