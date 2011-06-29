package DataFlow::Proc::MultiPageURLGenerator;

use strict;
use warnings;

# ABSTRACT: A processor that generates multi-paged URL lists

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use Carp;

has 'first_page' => (
    'is'      => 'ro',
    'isa'     => 'Int',
    'default' => 1,
);

has 'last_page' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
    'lazy'     => 1,
    'default'  => sub {
        my $self = shift;

        #warn 'last_page';
        confess(q{DataFlow::Proc::MultiPageURLGenerator: paged_url not set!})
          unless $self->has_paged_url;
        return $self->produce_last_page->( $self->_paged_url );
    },
);

# calling convention for the sub:
#   - $self
#   - $url (Str)
has 'produce_last_page' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub { confess(q{produce_last_page not implemented!}); },
);

# calling convention for the sub:
#   - $self
#   - $paged_url (Str)
#   - $page      (Int)
has 'make_page_url' => (
    'is'       => 'ro',
    'isa'      => 'CodeRef',
    'required' => 1,
);

has '_paged_url' => (
    'is'        => 'rw',
    'isa'       => 'Str',
    'predicate' => 'has_paged_url',
    'clearer'   => 'clear_paged_url',
);

sub _build_p {
    my $self = shift;

    return sub {
        my $url = $_;

        $self->_paged_url($url);

        my $first = $self->first_page;
        my $last  = $self->last_page;
        $first = 1 + $last + $first if $first < 0;

        my @result =
          map { $self->make_page_url->( $self, $url, $_ ) } $first .. $last;

        $self->clear_paged_url;
        return [@result];
    };
}

__PACKAGE__->meta->make_immutable;

1;

