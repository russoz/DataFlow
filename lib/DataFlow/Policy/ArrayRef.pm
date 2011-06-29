package DataFlow::Policy::ArrayRef;

use strict;
use warnings;

# ABSTRACT: A ProcPolicy that accepts only array-references

# VERSION

use Moose;
with 'DataFlow::Role::ProcPolicy';

use namespace::autoclean;

sub _build_handlers {
    return { 'ARRAY' => \&_handle_svalue, };
}

sub _build_default_handler {
    return sub { die q{Must be an array reference!}; };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

