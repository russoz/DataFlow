package DataFlow::Proc::MessagePack;

use strict;
use warnings;

# ABSTRACT: A MessagePack converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::Converter' => {
    type_attr  => 'msgpack',
    type_short => 'msgpack',
    type_class => 'Data::MessagePack',
};

use namespace::autoclean;
use Data::MessagePack;

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'TO_MSGPACK' ? 'ArrayRef' : 'Scalar';
    },
);

has '+p' => (
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

        return $subs->{ $self->direction };
    },
);

__PACKAGE__->meta->make_immutable;

1;

