package DataFlow::Chain;

#ABSTRACT: A "super-node" that can link a sequence of nodes

use strict;
use warnings;

# VERSION

use Moose;
extends 'DataFlow::Node';

use DataFlow::Node;
use List::Util qw/reduce/;

has 'links' => (
    'is'       => 'ro',
    'isa'      => 'ArrayRef[DataFlow::Node]',
    'required' => 1,
);

sub _first_link { return shift->links->[0] }
sub _last_link  { return shift->links->[-1] }

has '+process_item' => (
    'default' => sub {
        return sub {
            my ( $self, $item ) = @_;

            #use Data::Dumper;
            #warn 'chain          = '.Dumper($self);
            #warn 'chain :: links = '.Dumper($self->links);
            $self->confess('Chain has no nodes, cannot process_item()')
              unless scalar @{ $self->links };

            $self->_first_link->input($item);
            return $self->_reduce->output;
        },;
    },
);

sub _reduce {
    return reduce {
        $a->process_input;

        # always flush the output queue
        $b->input( $a->output );
        $b;
    }
    @{ shift->links };
}

override 'process_input' => sub {
    my $self = shift;
    return unless ( $self->has_input || $self->_chain_has_data );

    # empty existing data in the pipe
    while ( $self->_chain_has_data ) {
        my $last = $self->_reduce;
        $self->_add_output( $last->output );
    }

    unless ( $self->has_output ) {
        my $item = $self->_dequeue_input;
        $self->_add_output( $self->_handle_list($item) );
    }
};

sub _chain_has_data {
    return 0 != scalar( grep { $_->has_input } @{ shift->links } );
}

before 'flush' => sub {
    my $self = shift;
    $self->_first_link->input( $self->_dequeue_input );
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Node;
    use DataFlow::Chain;

    my $chain = DataFlow::Chain->new(
        links => [
            DataFlow::Node->new(
                process_item => sub {
                    shift; return uc(shift);
                }
            ),
            DataFlow::Node->new(
                process_item => sub {
                    shift; return reverse shift ;
                }
            ),
        ],
    );

    my $result = $chain->process( 'abc' );
    # $result == 'CBA'

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a chain of steps in
a data-flow.
One might think of it as the actual definition of the data flow, but this is a
limited, linear, flow, and there is room for a lot of improvements.

A C<DataFlow::Chain> object accepts input like a regular
C<DataFlow::Node>, but it injects that input into the first link of the
chain, and pumps the output of each link into the input of the next one,
similarly to pipes in a shell command line. The output of the last link of the
chain will be used as the output of the entire chain.

=head1 DEPENDENCIES

L<DataFlow::Node>

L<List::Util>

=cut
