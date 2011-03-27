package DataFlow::Proc::Null;

use strict;
use warnings;

# ABSTRACT: A 'null' processor, will discard any input and return undef in the output
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';

has '+process_into' => (
    'default'  => 0,
    'init_arg' => undef,
);

has '+p' => (
    'default' => sub {
        return sub { }
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Null;

    my $null = DataFlow::Proc::Null->new;

    my $result = $null->process( 'abc' );
    # $result == undef

=head1 DESCRIPTION

This class represents a null processor: it will return C<undef> regardless of
any input provided to it.

=head1 METHODS

The interface for C<DataFlow::Proc::Null> is the same of
C<DataFlow::Proc>.

=cut
