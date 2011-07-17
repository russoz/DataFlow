package DataFlow::Proc::Encoding;

use strict;
use warnings;

# ABSTRACT: A encoding conversion processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use DataFlow::Types qw(Encoder Decoder);

use namespace::autoclean;
use MooseX::Aliases;

has 'input_decoder' => (
    'is'      => 'ro',
    'isa'     => 'Decoder',
    'coerce'  => 1,
    'lazy'    => 1,
    'builder' => '_build_encoder',
    'alias'   => 'from',
);

sub _build_encoder {
    return sub { $_[0] }
}

has 'output_encoder' => (
    'is'      => 'ro',
    'isa'     => 'Encoder',
    'coerce'  => 1,
    'lazy'    => 1,
    'builder' => '_build_decoder',
    'alias'   => 'to',
);

sub _build_decoder {
    return sub { $_[0] }
}

sub _build_p {
    my $self = shift;
    return sub {
        my $internal = $self->input_decoder->($_);
        return $self->output_encoder->($internal);
    };
}

__PACKAGE__->meta->make_immutable;

1;

