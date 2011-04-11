package DataFlow::ProcHandler::ProcessInto;

use strict;
use warnings;

# ABSTRACT: A ProcHandler that processes only scalar values, no refs

# VERSION

use Moose;
with 'DataFlow::Role::ProcHandler';

has '_handlers' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[CodeRef]',
    'lazy'    => 1,
    'default' => sub {
        my $me           = shift;
        my $type_handler = {
            'SVALUE' => \&_handle_svalue,
            'OBJECT' => \&_handle_svalue,
            'SCALAR' => \&_handle_scalar_ref,
            'ARRAY'  => \&_handle_array_ref,
            'HASH'   => \&_handle_hash_ref,
            'CODE'   => \&_handle_code_ref,
        };
        return $type_handler;
    },
);

sub _handle {
    my ( $p, $item, $type ) = @_;

    return $self->_handlers->{$type}->($p,$item);
}

__PACKAGE__->meta->make_immutable;
no Moose::Util::TypeConstraints;
no Moose;

1;

__END__

