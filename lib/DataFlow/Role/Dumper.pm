package DataFlow::Role::Dumper;

use strict;
use warnings;

# ABSTRACT: A role that provides a facility for dumping data to STDERR

# VERSION

use Moose::Role;
use Moose::Autobox;

has '_dumper' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub {
        use Data::Dumper;
        return sub {
            $Data::Dumper::Terse = 1;
			return @_->map( sub { Dumper($_) } )->join( qq{\n} );
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

has 'dump_input' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the input load to STDERR',
);

has 'dump_output' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the output load to STDERR',
);

1;

__END__

=pod

=cut
