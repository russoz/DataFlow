package DataFlow::Policy::ArrayRef;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that accepts only array-references

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

has '+handlers' => (
    'default' => sub {
        return { 'ARRAY' => \&_handle_svalue, };
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

