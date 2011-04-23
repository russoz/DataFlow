package DataFlow::TypePolicy::ArrayRef;

use strict;
use warnings;

# ABSTRACT: A TypePolicy that processes only array references

# VERSION

use Moose;
with 'DataFlow::Role::TypePolicy';

use namespace::autoclean;

has '+default_handler' => (
    'default' => sub {
        return \&_handle_array_ref;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

