package DataFlow::Policy::ProcessIntoArrayRef;

use strict;
use warnings;

# ABSTRACT: A Policy that processes into array references only

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

sub _build_handlers {
    return { 'ARRAY' => \&_handle_array_ref, };
}

sub _build_default_handler {
    return sub { die q{Must be an array reference!} };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

