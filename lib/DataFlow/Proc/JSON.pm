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
    handles => {
        'json'          => sub { shift->converter(@_) },
        'json_opts'     => sub { shift->converter_opts(@_) },
        'has_json_opts' => sub { shift->has_converter_opts },
    },
    init_arg => 'json',
);

has '+converter_opts' => ( 'init_arg' => 'json_opts', );

has '+converter_subs' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;
        return {
            'CONVERT_TO' => sub {
                my $data = shift;
                return $self->converter->to_json($data);
            },
            'FROM_JSON' => sub {
                my $json = shift;
                return $self->converter->from_json($json);
            },
        };
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

