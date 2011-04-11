package DataFlow::Role::ProcHandler;

use strict;
use warnings;

# ABSTRACT: A role that defines a proc-handler

# VERSION

use Moose::Role;

use Scalar::Util qw/blessed reftype/;

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return 'SVALUE' unless $r;
    return 'OBJECT' if blessed($p);
    return $r;
}

requires '_handle';

sub handle {
	my ($p, $item) = @_;
	my $type = _param_type($item);
	return _handle( $p, $item, $type );
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

