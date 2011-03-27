package DataFlow::Role::Dumper;

use strict;
use warnings;

# ABSTRACT: A role that provides a facility for dumping data to STDERR
# ENCODING: utf8

# VERSION

use Moose::Role;

has '_dumper' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub {
        use Data::Dumper;
        return sub {
            return Dumper(@_);
        };
    },
    'handles' => {
        'prefix_dumper' => sub {
            my ( $self, $prefix, @args ) = @_;
            print STDERR $prefix;
            if (@args) {
                print STDERR ' ' . $self->_dumper->(@args);
            }
            else {
                print STDERR "\n";
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
