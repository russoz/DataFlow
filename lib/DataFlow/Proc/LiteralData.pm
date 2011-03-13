package DataFlow::Proc::LiteralData;

use strict;
use warnings;

# ABSTRACT: A fixed-output processor
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';

with 'MooseX::OneArgNew' => {
    'type'     => 'Any',
    'init_arg' => 'data',
};

has 'infinite' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'data' => (
    'is'       => 'rw',
    'isa'      => 'Any',
    'clearer'  => 'clear_data',
    'required' => 1,
);

has '+allows_undef_input' => ( 'default' => 1, );

has '+p' => (
    default => sub {
        my $self = shift;
        return sub {
            my $item = $self->data;
            $self->clear_data unless $self->infinite;
            return $item;
          }
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

