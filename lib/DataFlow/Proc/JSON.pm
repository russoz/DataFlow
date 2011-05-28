package DataFlow::Proc::JSON;

use strict;
use warnings;

# ABSTRACT: A JSON converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use JSON::Any;

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
          ? JSON::Any->new( $self->converter_opts )
          : JSON::Any->new;
    },
);

has '+converter_subs' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'CONVERT_TO' => sub {
                my $data = shift;
                return $self->converter->to_json($data);
            },
            'FROM_JSON' => sub {
                my $json = shift;
                return $self->converter->from_json($json);
            },
        };
        return $subs;
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

