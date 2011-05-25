package DataFlow::Proc::Encoding;

use strict;
use warnings;

# ABSTRACT: A encoding conversion processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use Moose::Util::TypeConstraints 1.01;

use namespace::autoclean;
use Encode;
use MooseX::Aliases;

subtype 'Decoder' => as 'CodeRef';
coerce 'Decoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return decode( $encoding, shift ) };
};

subtype 'Encoder' => as 'CodeRef';
coerce 'Encoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return encode( $encoding, shift ) };
};

has 'input_decoder' => (
    'is'      => 'ro',
    'isa'     => 'Decoder',
    'coerce'  => 1,
    'lazy'    => 1,
    'default' => sub {
        sub { $_[0] }
    },
    'alias' => 'from',
);

has 'output_encoder' => (
    'is'      => 'ro',
    'isa'     => 'Encoder',
    'coerce'  => 1,
    'lazy'    => 1,
    'default' => sub {
        sub { $_[0] }
    },
    'alias' => 'to',
);

has '+p' => (
    'default' => sub {
        my $self = shift;
        return sub {
            my $internal = $self->input_decoder->(shift);
            return $self->output_encoder->($internal);
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

