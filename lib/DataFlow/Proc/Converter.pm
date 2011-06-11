package DataFlow::Proc::Converter;

use strict;
use warnings;

# ABSTRACT: A generic processor for format-conversion

# VERSION

use Moose;
extends 'DataFlow::Proc';

use DataFlow::Types qw(ConversionDirection ConversionSubs);

has 'direction' => (
    is       => 'ro',
    isa      => 'ConversionDirection',
    required => 1,
);

has 'converter_subs' => (
    is       => 'ro',
    isa      => 'ConversionSubs',
    required => 1,
);

has 'converter_opts' => (
    is        => 'ro',
    isa       => 'Any',
    predicate => 'has_converter_opts',
);

has 'converter' => ( is => 'ro', );

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;
        return $self->converter_subs->{ $self->direction };
    },
);

1;

