package DataFlow::Proc::URLRetriever;

use strict;
use warnings;

# ABSTRACT: An URL-retriever node
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';

use DataFlow::Node::URLRetriever::Get;

has '_get' => (
    'is'      => 'ro',
    'isa'     => 'DataFlow::Node::URLRetriever::Get',
    'lazy'    => 1,
    'default' => sub { DataFlow::Node::URLRetriever::Get->new }
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
            my $item = shift;

            my $url =
              $self->has_baseurl
              ? URI->new_abs( $item, $self->baseurl )->as_string
              : $item;

            #$self->debug("process_item:: url = $url");
            return $self->_get->get($url);
        };
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

