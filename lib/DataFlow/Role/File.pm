package DataFlow::Role::File;

#ABSTRACT: A role that provides a file-handle for nodes

use strict;
use warnings;

# VERSION

use Moose::Role;
use MooseX::Types::IO 'IO';

has _handle => (
    is        => 'rw',
    isa       => 'IO',
    coerce    => 1,
    predicate => 'has_handle',
    clearer   => 'clear_handle',
);

has nochomp => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has do_slurp => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

sub _check_eof {
    my $self = shift;
    if ( $self->_handle->eof ) {
        $self->_handle->close;
        $self->clear_handle;
    }
    return;
}

1;

