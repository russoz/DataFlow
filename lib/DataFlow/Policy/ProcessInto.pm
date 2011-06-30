package DataFlow::Policy::ProcessInto;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that processes into references' values recursively

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

sub _build_handlers {
    my $self         = shift;
    my $type_handler = {
        'SCALAR' => sub {
            my ( $p, $item ) = @_;
            return _handle_scalar_ref( _make_apply_ref( $self, $p ), $item );
        },
        'ARRAY' => sub {
            my ( $p, $item ) = @_;
            return _handle_array_ref( _make_apply_ref( $self, $p ), $item );
        },
        'HASH' => sub {
            my ( $p, $item ) = @_;
            return _handle_hash_ref( _make_apply_ref( $self, $p ), $item );
        },
        'CODE' => sub {
            my ( $p, $item ) = @_;
            return _handle_code_ref( _make_apply_ref( $self, $p ), $item );
        },
    };
    return $type_handler;
}

sub _build_default_handler {
    return \&_handle_svalue;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

