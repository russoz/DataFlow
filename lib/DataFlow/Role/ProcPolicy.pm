package DataFlow::Role::ProcPolicy;

use strict;
use warnings;

# ABSTRACT: A role that defines how to use proc-handlers

# VERSION

use Moose::Role;
use Moose::Autobox;

use namespace::autoclean;
use Scalar::Util 'reftype';

has 'handlers' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[CodeRef]',
    'lazy'    => 1,
    'builder' => '_build_handlers',
);

sub _build_handlers {
    return {};
}

has 'default_handler' => (
    'is'       => 'ro',
    'isa'      => 'CodeRef',
    'required' => 1,
    'builder'  => '_build_default_handler',
);

sub _build_default_handler {
    return;
}

sub apply {
    my ( $self, $p, $item ) = @_;
    my $type = _param_type($item);

    my $handler =
      exists $self->handlers->{$type}
      ? $self->handlers->{$type}
      : $self->default_handler;

    return $handler->( $p, $item );
}

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return $r ? $r : 'SVALUE';
}

sub _make_apply_ref {
    my ( $self, $p ) = @_;
    return sub { $self->apply( $p, $_ ) };
}

sub _run_p {
    my ( $p, $item ) = @_;
    local $_ = $item;
    return $p->();
}

sub _nop_handle {
    my @param = @_;      # ( p, item )
    return $param[1];    # nop handle: ignores p, returns item itself
}

sub _handle_svalue {
    my ( $p, $item ) = @_;
    return _run_p( $p, $item );
}

sub _handle_scalar_ref {
    my ( $p, $item ) = @_;
    my $r = _run_p( $p, $$item );
    return \$r;
}

sub _handle_array_ref {
    my ( $p, $item ) = @_;
    return $item->map( sub { _run_p( $p, $_ ) } );
}

sub _handle_hash_ref {
    my ( $p, $item ) = @_;
    return { @{ $item->keys->map( sub { $_ => _run_p( $p, $item->{$_} ) } ) } };
}

sub _handle_code_ref {
    my ( $p, $item ) = @_;
    return sub { _run_p( $p, $item->() ) };
}

1;

=pod

=head2 apply P ITEM

Applies this policy to the data ITEM using function P.

=cut

