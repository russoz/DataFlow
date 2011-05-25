package DataFlow::Item;

use strict;
use warnings;

# ABSTRACT: A piece of information to be processed

# VERSION

use Moose;
use DataFlow::Meta;

use namespace::autoclean;

has 'metadata' => (
    'is'  => 'ro',
    'isa' => 'DataFlow::Meta',
);

has 'data' => (
    'is'  => 'ro',
    'isa' => 'Any',
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Item;

=head1 DESCRIPTION


=cut
