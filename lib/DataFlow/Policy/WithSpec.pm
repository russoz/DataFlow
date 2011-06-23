package DataFlow::Policy::WithSpec;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that treats scalars items and pass other types as-is.

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

has 'spec' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub _spec_handle {
    my ( $spec, $p, $item ) = @_;

    my $piece = '$item' . $spec;
    my $data  = eval $piece;           ## no critic
    my @r     = _run_p( $p, $data );
    eval $piece . '= $r[0]';           ## no critic
    return $item;
}

has '+handlers' => ( 'default' => sub { return {} }, );

has '+default_handler' => (
    'default' => sub {
        my $self = shift;
        return sub {
            my ( $p, $item ) = @_;
            _spec_handle( $self->spec, $p, $item );
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

