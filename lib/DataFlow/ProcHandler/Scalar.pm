package DataFlow::ProcHandler::Scalar;

use strict;
use warnings;

# ABSTRACT: A ProcHandler that processes only scalar values, no refs

# VERSION

use Moose;
with 'DataFlow::Role::ProcHandler';

use namespace::autoclean;

has '+default_handler' => (
    'default' => sub {
        return \&_handle_svalue;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

