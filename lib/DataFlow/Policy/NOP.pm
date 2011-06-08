package DataFlow::Policy::NOP;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that returns the very item passed

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

has '+default_handler' => ( 'default' => sub { return \&_nop_handle } );

__PACKAGE__->meta->make_immutable;

1;

__END__

