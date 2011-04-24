package DataFlow::Role::Dumper;

use strict;
use warnings;

# ABSTRACT: A role that provides a facility for dumping data to STDERR

# VERSION

use Moose::Role;

has '_dumper' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub {
        use Data::Dumper;
        $Data::Dumper::Terse = 1;
        return sub {
            return Dumper(@_);
        };
    },
    'handles' => {
        'prefix_dumper' => sub {
            my ( $self, $prefix, @args ) = @_;
            foreach (@args) {
                print STDERR $prefix . ' ' . $self->_dumper->($_);
            }
        },
        'raw_dumper' => sub {
            my $self = shift;
            print STDERR $self->_dumper->(@_);
        },
    },
);

1;

__END__

=pod

=cut
