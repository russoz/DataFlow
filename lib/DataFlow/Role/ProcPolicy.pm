package DataFlow::Role::ProcPolicy;

use strict;
use warnings;

# ABSTRACT: A role that defines how to use proc-handlers

# VERSION

use Moose::Role;

use namespace::autoclean;
use Scalar::Util 'reftype';

has 'handlers' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[CodeRef]',
    'lazy'    => 1,
    'default' => sub { return {} },
);

has 'default_handler' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub {
        shift->confess(q{Must provide a default handler!});
    },
);

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

sub _nop_handle {    ## no critic
    return $_;
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

    #use Data::Dumper; warn 'handle_array_ref :: item = ' . Dumper($item);
    my @r = map { _run_p( $p, $_ ) } @{$item};
    return [@r];
}

sub _handle_hash_ref {
    my ( $p, $item ) = @_;
    my %r = map { $_ => _run_p( $p, $item->{$_} ) } keys %{$item};
    return {%r};
}

sub _handle_code_ref {
    my ( $p, $item ) = @_;
    return sub { _run_p( $p, $item->() ) };
}

1;

=pod

=head2 apply P ITEM

Applies the policy using function P and input data ITEM.

=cut

