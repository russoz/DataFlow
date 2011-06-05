package DataFlow::Proc::URLRetriever;

use strict;
use warnings;

# ABSTRACT: An URL-retriever processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use DataFlow::Util::HTTPGet;

has '_get' => (
    'is'      => 'ro',
    'isa'     => 'DataFlow::Util::HTTPGet',
    'lazy'    => 1,
    'default' => sub { DataFlow::Util::HTTPGet->new }
);

has 'baseurl' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_baseurl',
);

has '+p' => (
    'default' => sub {
        my $self = shift;

        return sub {
            my $url =
              $self->has_baseurl
              ? URI->new_abs( $_, $self->baseurl )->as_string
              : $_;

            #$self->debug("process_item:: url = $url");
            return $self->_get->get($url);
        };
    },
);

__PACKAGE__->meta->make_immutable;

1;

