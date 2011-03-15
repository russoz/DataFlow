package DataFlow::Proc::NOP;

use strict;
use warnings;

# ABSTRACT: A No-Op node, input data is passed unmodified to the output
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';

has '+p' => (
    'default' => sub {
        return sub { return $_[0]; }
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc::NOP;

    my $nop = DataFlow::Proc::NOP->new;

    my $result = $nop->process_one( 'abc' );
    # $result == 'abc'

=head1 DESCRIPTION

This class represents a no-op processor: the very input is passed without
modifications to the output.

This class is more useful as parent class than by itself.

=head1 METHODS

The interface for C<DataFlow::Proc::NOP> is the same of
C<DataFlow::Proc>.

=cut