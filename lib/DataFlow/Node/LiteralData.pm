package DataFlow::Node::LiteralData;

#ABSTRACT: A node provides its initialization data for flow processing

use strict;
use warnings;

# VERSION

use Moose;
extends 'DataFlow::Node::NOP';
with 'MooseX::OneArgNew' => {
    type     => 'Any',
    init_arg => 'data',
};

has data => (
    is        => 'ro',
    isa       => 'Any',
    clearer   => 'clear_data',
    predicate => 'has_data',
    required  => 1,
    trigger   => sub {
        my $self = shift;
        if ( $self->has_data ) {
            $self->_add_input(@_);
            $self->clear_data;
        }
    },
);

override 'input' => sub { };

__PACKAGE__->meta->make_immutable;

1;

