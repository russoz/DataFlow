package DataFlow::Role::Processor;

use strict;
use warnings;

# ABSTRACT: A role that defines anything that processes something

# VERSION

use Moose::Role;

requires 'process';

1;

