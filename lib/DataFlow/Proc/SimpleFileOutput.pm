package DataFlow::Proc::SimpleFileOutput;

use strict;
use warnings;

# ABSTRACT: A processor that writes data to a file

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::File';

use namespace::autoclean;

has 'ors' => (
    'is'            => 'ro',
    'isa'           => 'Str',
    'lazy'          => 1,
    'default'       => "\n",
    'predicate'     => 'has_ors',
    'documentation' => 'Output record separator',
);

has '+p' => (
    'default' => sub {
        my $self = shift;

        return sub {
            my $fh = $self->file;
            local $\ = $self->ors if $self->has_ors;
            print $fh $_;
            return $_;
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

