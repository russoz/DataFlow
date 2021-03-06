package DataFlow::Role::File;

use strict;
use warnings;

# ABSTRACT: A role that provides a file-handle for processors

# VERSION

use Moose::Role;
use MooseX::Types::IO 'IO';

has 'file' => (
    'is'        => 'rw',
    'isa'       => 'IO',
    'coerce'    => 1,
    'predicate' => 'has_file',
    'clearer'   => 'clear_file',
);

has 'nochomp' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'do_slurp' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

sub _check_eof {
    my $self = shift;
    if ( $self->file->eof ) {
        $self->file->close;
        $self->clear_file;
    }
    return;
}

1;

