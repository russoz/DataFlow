package DataFlow::Proc::JSON;

use strict;
use warnings;

# ABSTRACT: A JSON converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::Converter' => {
    type_attr  => 'json',
    type_short => 'json',
    type_class => 'JSON::Any',
};

use namespace::autoclean;
use JSON::Any;

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'TO_JSON' ? 'ArrayRef' : 'Scalar';
    },
);

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'TO_JSON' => sub {
                my $data = shift;
                return $self->json->to_json($data);
            },
            'FROM_JSON' => sub {
                my $json = shift;
                return $self->json->from_json($json);
            },
        };

        return $subs->{ $self->direction };
    },
);

__PACKAGE__->meta->make_immutable;

1;

