package DataFlow::Proc::Encoding;

use strict;
use warnings;

# ABSTRACT: A encoding conversion node
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';

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
            return $item unless ref($item) ne '';
            my $data =
              $self->has_input_encoding
              ? decode( $self->input_encoding, $item )
              : $item;
            return $self->has_output_encoding
              ? encode( $self->output_encoding, $data )
              : $data;
        };
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

