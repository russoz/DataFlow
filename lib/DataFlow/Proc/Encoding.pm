package DataFlow::Proc::Encoding;

use strict;
use warnings;

# ABSTRACT: A encoding conversion processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use Encode;

has 'input_encoding' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_input_encoding',
);

has 'output_encoding' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_output_encoding',
);

has '+p' => (
    'default' => sub {
        my $self = shift;
        return sub {
            my $item = shift;
            return $item unless ref($item) eq '';
            my $internal =
              $self->has_input_encoding
              ? decode( $self->input_encoding, $item )
              : $item;
            return $self->has_output_encoding
              ? encode( $self->output_encoding, $internal )
              : $internal;
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

