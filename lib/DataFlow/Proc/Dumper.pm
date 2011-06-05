package DataFlow::Proc::Dumper;

use strict;
use warnings;

# ABSTRACT: [DEPRECATED] A debugging processor that will dump data to STDERR

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::Dumper';

use namespace::autoclean;

has '+process_into' => (
    default  => 0,
    init_arg => undef,
);
has '+p' => (
    'default' => sub {
        my $self = shift;
        return sub {
            $self->raw_dumper($_);
            return $_;
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc::Dumper;

    my $dump = DataFlow::Proc::Dumper->new;

    my $result = $dump->process+one( 'abc' );
    # $result == 'abc'

=head1 DESCRIPTION

B<DEPRECATED:> Every processor now has its own data-dumping facility, by
using the attributes C<dump_input> and C<dump_output>.

Dumper processor. Every item passed to its input will be printed in the C<STDERR>
file handle, using the method C<raw_dumper()> defined at the role
L<DataFlow::Role::Dumper>.

=head1 SEE ALSO

L<DataFlow::Proc>

=cut
