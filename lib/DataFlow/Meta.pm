package DataFlow::Meta;

use strict;
use warnings;

# ABSTRACT: A piece of information metadata
# ENCODING: utf8

# VERSION

use Moose;
use DateTime;

has 'timestamp'    => ( is => 'rw', isa => 'DateTime', );
has 'title'        => ( is => 'rw', isa => 'Str', );
has 'publisher'    => ( is => 'rw', isa => 'Str', );
has 'author'       => ( is => 'rw', isa => 'Str', );
has 'original'     => ( is => 'rw', isa => 'Str', );
has 'restrictions' => ( is => 'rw', isa => 'Str', );

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=cut
