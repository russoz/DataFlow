package DataFlow::Proc::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

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
        return 0 if $self->direction eq 'CONVERT_FROM';
        return 1 if $self->has_header;
        return 0;
    },
);

has '+converter' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;
        return $self->has_converter_opts
          ? Text::CSV::Encoded->new( $self->converter_opts )
          : Text::CSV::Encoded->new;
    },
);

sub _combine {
    my ( $self, $e ) = @_;
    my $status = $self->converter->combine( @{$e} );
    die $self->converter->error_diag unless $status;
    return $self->converter->string;
}

sub _parse {
    my ( $self, $line ) = @_;
    my $ok = $self->converter->parse($line);
    die $self->converter->error_diag unless $ok;
    return [ $self->converter->fields ];
}

has '+type_policy' => (
    'default' => sub {
        return shift->direction eq 'CONVERT_TO' ? 'ArrayRef' : 'Scalar';
    },
);

has '+converter_subs' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $subs = {
            'CONVERT_TO' => sub {
                my $data = shift;
                my @res  = ();
                if ( $self->header_wanted ) {
                    $self->header_wanted(0);
                    push @res, $self->_combine( $self->header );
                }

                push @res, $self->_combine($data);
                return @res;
            },
            'CONVERT_FROM' => sub {
                my $csv_line = shift;
                if ( $self->header_wanted ) {
                    $self->header_wanted(0);
                    $self->header( $self->_parse($csv_line) );
                    return;
                }
                return $self->_parse($csv_line);
            },
        };

        return $subs;
    },
    'init_arg' => undef,
);

__PACKAGE__->meta->make_immutable;

1;

