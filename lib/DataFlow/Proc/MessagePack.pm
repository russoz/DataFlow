package DataFlow::Proc::MessagePack;

use strict;
use warnings;

# ABSTRACT: A MessagePack converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use Data::MessagePack;

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'CONVERT_TO' ? 'ArrayRef' : 'Scalar';
    },
);

has '+converter' => (
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->has_converter_opts
          ? Data::MessagePack->new( $self->converter_opts )
          : Data::MessagePack->new;
    },
);

has '+converter_subs' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'TO_MSGPACK' => sub {
                my $data = shift;
                return $self->msgpack->pack($data);
            },
            'FROM_MSGPACK' => sub {
                my $msgpack = shift;
                return $self->msgpack->unpack($msgpack);
            },
        };

        return $subs;
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

