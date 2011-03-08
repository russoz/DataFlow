package DataFlow::Node::SimpleFileOutput;

use strict;
use warnings;

# ABSTRACT: A node that writes data to a file
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Node';
with 'DataFlow::Role::File';

has 'ors' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'lazy'          => 1,
    'default'       => "\n",
    'predicate'     => 'has_ors',
    'documentation' => 'Output record separator',
);

has '+process_item' => (
    'default' => sub {
        return sub {
            my ( $self, $item ) = @_;
            my $fh = $self->file;
            local $\ = $self->ors if $self->has_ors;
            print $fh $item;
            return $item;
          }
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

