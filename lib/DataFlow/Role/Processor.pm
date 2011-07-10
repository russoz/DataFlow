package DataFlow::Role::Processor;

use strict;
use warnings;

# ABSTRACT: A role that defines anything that processes something

# VERSION

use Moose::Role;

has 'name' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_name',
);

requires 'process';

1;

