package DataFlow::Proc::Converter;

use strict;
use warnings;

# ABSTRACT: A generic processor for format-conversion

# VERSION

use Moose;
extends 'DataFlow::Proc';

use DataFlow::Types qw(ConversionDirection ConversionSubs);

use namespace::autoclean;

has 'direction' => (
    is       => 'ro',
    isa      => 'ConversionDirection',
    required => 1,
);

has 'converter_subs' => (
    is       => 'ro',
    isa      => 'ConversionSubs',
    lazy     => 1,
    required => 1,
    builder  => '_build_subs',
);

has 'converter_opts' => (
    is        => 'ro',
    isa       => 'Any',
    predicate => 'has_converter_opts',
);

has 'converter' => ( is => 'ro', );

sub _build_subs {
    return;
}

sub _build_p {
    my $self = shift;
    return $self->converter_subs->{ $self->direction };
}

1;

