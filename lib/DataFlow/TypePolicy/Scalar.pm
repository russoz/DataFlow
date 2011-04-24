package DataFlow::TypePolicy::Scalar;

use strict;
use warnings;

# ABSTRACT: A TypePolicy that treats all items as scalars

# VERSION

use Moose;
with 'DataFlow::Role::TypePolicy';

use namespace::autoclean;

has '+default_handler' => (
    'default' => sub {
        return \&_handle_svalue;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

