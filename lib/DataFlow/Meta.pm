package DataFlow::Meta;

#ABSTRACT: A piece of information metadata

use strict;
use warnings;

# VERSION

use Moose;
use DateTime;

has timestamp    => ( is => 'rw', isa => 'DateTime', );
has title        => ( is => 'rw', isa => 'Str', );
has publisher    => ( is => 'rw', isa => 'Str', );
has author       => ( is => 'rw', isa => 'Str', );
has original     => ( is => 'rw', isa => 'Str', );
has restrictions => ( is => 'rw', isa => 'Str', );

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=head1 METHODS

TODO

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-dataflow@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=cut
