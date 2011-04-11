package DataFlow::Proc::Dumper;

use strict;
use warnings;

# ABSTRACT: A debugging processor that will dump data to STDERR

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::Dumper';

has '+process_into' => (
    default  => 0,
    init_arg => undef,
);
has '+p' => (
    'default' => sub {
        my $self = shift;
        return sub {
            my $item = shift;
            $self->raw_dumper($item);
            return $item;
        };
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc::Dumper;

    my $dump = DataFlow::Proc::Dumper->new;

    my $result = $dump->process+one( 'abc' );
    # $result == 'abc'

=head1 DESCRIPTION

Dumper processor. Every item passed to its input will be printed in the C<STDERR>
file handle, using the method C<raw_dumper()> defined at the role
L<DataFlow::Role::Dumper>.

=cut
