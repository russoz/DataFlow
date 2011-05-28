package DataFlow::Proc::YAML;

use strict;
use warnings;

# ABSTRACT: A YAML converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use YAML::Any;

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'TO_YAML' ? 'ArrayRef' : 'Scalar';
    },
);

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'TO_YAML' => sub {
                my $data = shift;
                return Dump($data);
            },
            'FROM_YAML' => sub {
                my $yaml = shift;
                return Load($yaml);
            },
        };

        return $subs->{ $self->direction };
    },
);

__PACKAGE__->meta->make_immutable;

1;

