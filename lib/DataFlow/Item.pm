package DataFlow::Item;

use strict;
use warnings;

# ABSTRACT: A piece of information to be processed

# VERSION

use Moose;
use DataFlow::Meta;

use namespace::autoclean;

has 'metadata' => (
    'is'  => 'ro',
    'isa' => 'DataFlow::Meta',
);

has 'data' => (
    'is'  => 'ro',
    'isa' => 'Any',
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Item;

=head1 DESCRIPTION


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

L<Scalar::Util>

L<Queue::Base>

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=cut
