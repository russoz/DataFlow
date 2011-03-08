package DataFlow::Node::Null;

#ABSTRACT: A null node, will discard any input and return undef in the output

use strict;
use warnings;

# VERSION

use Moose;
extends 'DataFlow::Node';

has '+process_into' => ( 'default' => 0, );

has '+process_item' => (
    'default' => sub {
        return sub { shift; return; }
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Null;

    my $null = DataFlow::Node::Null->new;

    my $result = $null->process( 'abc' );
    # $result == undef

=head1 DESCRIPTION

This class represents a null node: it will return undef regardless of any input
provided to it.

=head1 METHODS

The interface for C<DataFlow::Node::Null> is the same of
C<DataFlow::Node>.

=head1 DEPENDENCIES

L<DataFlow::Node>

=cut
