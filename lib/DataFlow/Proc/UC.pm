package DataFlow::Proc::UC;

use strict;
use warnings;

# ABSTRACT: Upper-case processor: output data is input passed through uc()

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;

has '+p' => (
    'default' => sub {
        return sub { uc }
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc::UC;

    my $nop = DataFlow::Proc::UC->new;

    my $result = $nop->process( 'abc' );
    # $result == 'ABC'

=head1 DESCRIPTION

This class transforms the data by applying the C<< uc() >> function to it.
Not really all that useful, but it can provide for some samples and tests.

This class is more useful as parent class than by itself.

=cut
