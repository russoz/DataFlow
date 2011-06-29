package DataFlow::Proc::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting processor

# VERSION

use Moose;
extends 'DataFlow::Proc::Converter';

use namespace::autoclean;
use Text::CSV::Encoded;
use MooseX::Aliases;

has 'header' => (
    'is'        => 'rw',
    'isa'       => 'ArrayRef[Maybe[Str]]',
    'predicate' => 'has_header',
    'alias'     => 'headers',
    'handles'   => { 'has_headers' => sub { shift->has_header }, },
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
    'handles' => {
        'text_csv'          => sub { shift->converter(@_) },
        'text_csv_opts'     => sub { shift->converter_opts(@_) },
        'has_text_csv_opts' => sub { shift->has_converter_opts },
    },
    'init_arg' => 'text_csv',
);

has '+converter_opts' => ( 'init_arg' => 'text_csv_opts', );

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

sub _policy {
    return shift->direction eq 'CONVERT_TO' ? 'ArrayRef' : 'Scalar';
}

sub _build_subs {
    my $self = shift;
    return {
        'CONVERT_TO' => sub {
            my @res = ();
            if ( $self->header_wanted ) {
                $self->header_wanted(0);
                push @res, $self->_combine( $self->header );
            }

            push @res, $self->_combine($_);
            return @res;
        },
        'CONVERT_FROM' => sub {
            if ( $self->header_wanted ) {
                $self->header_wanted(0);
                $self->header( $self->_parse($_) );
                return;
            }
            return $self->_parse($_);
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;

