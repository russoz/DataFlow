package DataFlow::Node::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting node
# VERSION

use Moose;
extends 'DataFlow::Node';

use Moose::Util::TypeConstraints;
use Text::CSV;

has 'headers' => (
    'is'        => 'ro',
    'isa'       => 'ArrayRef[Str]',
    'predicate' => 'have_headers',
);

has '_header_unused' => (
    'is'      => 'ro',
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
    'is'  => 'ro',
    'isa' => 'HashRef',
);

has 'csv' => (
    'is'      => 'ro',
    'isa'     => 'Text::CSV',
    'default' => sub {
        my $self = shift;

        my $make_csv = sub {
            return Text::CSV->new( $self->text_csv_opts );
        };
        return $make_csv->() unless $self->have_headers;

        # use headers
        if ( $self->direction eq 'TO_CSV' ) {
            $self->input( $self->headers );
        }

        return $make_csv->();
    },
);

before 'process_input' => sub {
    my $self = shift;
    return unless $self->direction eq 'TO_CSV';
    $self->add_output( $self->headers );
    $self->_use_header;
};

sub _to_csv {
    my ( $self, $data ) = @_;
    $self->csv->combine( @{$data} );
    return $self->csv->string;
}

sub _from_csv {
    my ( $self, $csvline ) = @_;
    $self->csv->parse($csvline);
    return [ $self->csv->fields ];
}

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

