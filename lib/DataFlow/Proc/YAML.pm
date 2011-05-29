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
                my $data = shift;
                return Dump($data);
            },
            'CONVERT_FROM' => sub {
                my $yaml = shift;
                return Load($yaml);
            },
        };
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

