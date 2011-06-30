package DataFlow::Proc::SQL;

use strict;
use warnings;

# ABSTRACT: A processor that generates SQL clauses

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use SQL::Abstract;

has '_sql' => (
    'is'      => 'ro',
    'isa'     => 'SQL::Abstract',
    'lazy'    => 1,
    'default' => sub { return SQL::Abstract->new; },
);

has 'table' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1
);

sub _build_p {
    my $self = shift;
    my $sql  = $self->_sql;

    return sub {
        my $data = $_;

        my ( $insert, @bind ) = $sql->insert( $self->table, $data );

        # TODO: regex ?
        map { $insert =~ s/\?/'$_'/; } @bind;
        print $insert . "\n";
      }
}

__PACKAGE__->meta->make_immutable;

1;

