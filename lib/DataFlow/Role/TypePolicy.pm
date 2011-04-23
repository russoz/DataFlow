package DataFlow::Role::TypePolicy;

use strict;
use warnings;

# ABSTRACT: A role that defines a proc-handler

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

    return
      exists $self->handlers->{$type}
      ? $self->handlers->{$type}->( $p, $item )
      : $self->default_handler->( $p, $item );
}

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return $r ? $r : 'SVALUE';
}

sub _handle_svalue {
    my ( $p, $item ) = @_;
    return $p->($item);
}

sub _handle_scalar_ref {
    my ( $p, $item ) = @_;
    my $r = $p->($$item);
    return \$r;
}

sub _handle_array_ref {
    my ( $p, $item ) = @_;

    #use Data::Dumper; warn 'handle_array_ref :: item = ' . Dumper($item);
    my @r = map { $p->($_) } @{$item};
    return [@r];
}

sub _handle_hash_ref {
    my ( $p, $item ) = @_;
    my %r = map { $_ => $p->( $item->{$_} ) } keys %{$item};
    return {%r};
}

sub _handle_code_ref {
    my ( $p, $item ) = @_;
    return sub { $p->( $item->() ) };
}

1;

=pod

=head2 apply P ITEM

Applies the policy using function P and input data ITEM.

=cut

