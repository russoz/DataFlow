package DataFlow::TypePolicy::ProcessIntoArrayRef;

use strict;
use warnings;

# ABSTRACT: A TypePolicy that processes into array references only

# VERSION

use Moose;
with 'DataFlow::Role::TypePolicy';

use namespace::autoclean;

has '+handlers' => (
    'default' => sub {
        return { 'ARRAY' => \&_handle_array_ref, };
    },
);

has '+default_handler' => (
    'default' => sub {
        die q{Must be an array reference!};
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

