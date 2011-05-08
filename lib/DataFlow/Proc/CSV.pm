package DataFlow::Proc::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::Converter' => {
	type_attr => 'text_csv',
	type_class => 'Text::CSV::Encoded',
	type_short => 'csv',
};

use namespace::autoclean;
use Text::CSV::Encoded;

has 'header' => (
    'is'        => 'rw',
    'isa'       => 'ArrayRef[Maybe[Str]]',
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

sub _combine {
    my ( $self, $e ) = @_;
    my $status = $self->text_csv->combine( @{$e} );
    die $self->text_csv->error_diag unless $status;
    return $self->text_csv->string;
}

sub _parse {
    my ( $self, $line ) = @_;
    my $ok = $self->text_csv->parse($line);
    die $self->text_csv->error_diag unless $ok;
    return [ $self->text_csv->fields ];
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

