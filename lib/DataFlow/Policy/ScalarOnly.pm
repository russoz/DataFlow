package DataFlow::Policy::ScalarOnly;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that treats all items as scalars

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

has '+default_handler' => (
    'default' => sub {
        return \&_handle_svalue;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

