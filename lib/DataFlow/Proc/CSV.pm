package DataFlow::Proc::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use Moose::Util::TypeConstraints 1.01;
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

has 'direction' => (
    'is'       => 'ro',
    'isa'      => enum( [qw/FROM_CSV TO_CSV/] ),
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

sub _parse {
    my ( $self, $line ) = @_;
    $self->csv->parse($line);
    return [ $self->csv->fields ];
}

has '+process_into' => ( 'default' => 0, );

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'TO_CSV' => sub {
                my $data = shift;
                my @res  = ();
                if ( $self->_header_unused ) {
                    $self->_header_unused(0);
                    push @res, $self->_combine( $self->headers );
                }

                push @res, $self->_combine($data);
                return @res;
            },
            'FROM_CSV' => sub {
                my $csv_line = shift;
                if ( $self->_header_unused ) {
                    $self->_header_unused(0);
                    $self->headers( $self->_parse($csv_line) );
                    return;
                }
                return $self->_parse($csv_line);
            },
        };

        return $subs->{ $self->direction };
    },
);

__PACKAGE__->meta->make_immutable;

1;

