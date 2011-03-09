package DataFlow::Node::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting node
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Node';

use Moose::Util::TypeConstraints;
use Text::CSV;

has 'headers' => (
    'is'        => 'rw',
    'isa'       => 'ArrayRef[Str]',
    'predicate' => 'have_headers',
);

has '_header_unused' => (
    'is'      => 'rw',
    'isa'     => 'Bool',
    'default' => 1,
    'clearer' => '_use_header',
);

enum '_direction_type' => [qw/FROM_CSV TO_CSV/];

has 'direction' => (
    'is'       => 'ro',
    'isa'      => '_direction_type',
    'required' => 1,
);

has 'text_csv_opts' => (
    'is'        => 'ro',
    'isa'       => 'HashRef',
    'predicate' => 'has_text_csv_opts',
);

has 'csv' => (
    'is'      => 'ro',
    'isa'     => 'Text::CSV',
    'default' => sub {
        my $self = shift;

        return $self->has_text_csv_opts
          ? Text::CSV->new( $self->text_csv_opts )
          : Text::CSV->new();
    },
);

sub _combine {
    my ( $self, $e ) = @_;
    $self->csv->combine( @{$e} );
    return $self->csv->string;
}

sub _to_csv {
    my ( $self, $data ) = @_;
    if ( $self->_header_unused ) {
        $self->_header_unused(0);
        return ( $self->_combine( $self->headers ), $self->_combine($data) );
    }

    return $self->_combine($data);
}

sub _parse {
    my ( $self, $line ) = @_;
    $self->csv->parse($line);
    return [ $self->csv->fields ];
}

sub _from_csv {
    my ( $self, $csv_line ) = @_;
    if ( $self->_header_unused ) {
        $self->_header_unused(0);
        $self->headers( $self->_parse($csv_line) );
        return;
    }
    return $self->_parse($csv_line);
}

has '+process_into' => ( 'default' => 0, );

has '+process_item' => (
    'lazy'    => 1,
    'default' => sub {
        return \&_to_csv if shift->direction eq 'TO_CSV';
        return \&_from_csv;
    }
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

