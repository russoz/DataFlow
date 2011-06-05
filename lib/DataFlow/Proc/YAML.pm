package DataFlow::Proc::YAML;

use strict;
use warnings;

# ABSTRACT: A YAML converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use YAML::Any;

has '+policy' => (
    'default' => sub {
        return shift->direction eq 'CONVERT_TO' ? 'ArrayRef' : 'Scalar';
    },
);

has '+converter_subs' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;
        return {
            'CONVERT_TO' => sub {
                return Dump($_);
            },
            'CONVERT_FROM' => sub {
                return Load($_);
            },
        };
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

