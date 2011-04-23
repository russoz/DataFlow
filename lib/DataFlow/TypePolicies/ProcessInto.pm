package DataFlow::TypePolicies::ProcessInto;

use strict;
use warnings;

# ABSTRACT: A ProcHandler that processes only scalar values, no refs

# VERSION

use Moose;
with 'DataFlow::Role::TypePolicy';

use namespace::autoclean;

has '+handlers' => (
    'default' => sub {
        my $me           = shift;
        my $type_handler = {
            'SCALAR' => \&_handle_scalar_ref,
            'ARRAY'  => \&_handle_array_ref,
            'HASH'   => \&_handle_hash_ref,
            'CODE'   => \&_handle_code_ref,
        };
        return $type_handler;
    },
);

has '+default_handler' => (
    'default' => sub {
        return \&_handle_svalue;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

