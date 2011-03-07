package DataFlow::Node::Dumper;

#ABSTRACT: A debugging node that will dump data to STDERR

use strict;
use warnings;

# VERSION

use Moose;
extends 'DataFlow::Node';

use Data::Dumper;

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $item ) = @_;
            $self->raw_dumper($item);
            return $item;
          }
    }
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Dumper;

    my $nop = DataFlow::Node::Dumper->new;

    my $result = $nop->process( 'abc' );
    # $result == undef

=head1 DESCRIPTION

Dumper node. Every item passed to its input will be printed in the C<STDERR>
file handle, using L<Data::Dumper>.

=head1 METHODS

The interface for C<DataFlow::Node::Dumper> is the same of
C<DataFlow::Node>.

=head1 DEPENDENCIES

L<Data::Dumper>

L<DataFlow::Node>

=cut
