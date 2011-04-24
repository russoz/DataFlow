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

has 'header' => (
    'is'        => 'rw',
    'isa'       => 'ArrayRef[Str]',
    'predicate' => 'has_header',
);

has 'header_wanted' => (
    'is'      => 'rw',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;
        return 0 if $self->direction eq 'FROM_CSV';
        return 1 if $self->has_header;
        return 0;
    },
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
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        return $self->has_text_csv_opts
          ? Text::CSV->new( $self->text_csv_opts )
          : Text::CSV->new();
    },
);

sub _combine {
    my ( $self, $e ) = @_;
    my $status = $self->csv->combine( @{$e} );
    die $self->csv->error_diag unless $status;
    return $self->csv->string;
}

sub _parse {
    my ( $self, $line ) = @_;
    $self->csv->parse($line);
    return [ $self->csv->fields ];
}

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'TO_CSV' ? 'ArrayRef' : 'Scalar';
    },
);

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'TO_CSV' => sub {
                my $data = shift;
                my @res  = ();
                if ( $self->header_wanted ) {
                    $self->header_wanted(0);
                    push @res, $self->_combine( $self->header );
                }

                push @res, $self->_combine($data);
                return @res;
            },
            'FROM_CSV' => sub {
                my $csv_line = shift;
                if ( $self->header_wanted ) {
                    $self->header_wanted(0);
                    $self->header( $self->_parse($csv_line) );
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

