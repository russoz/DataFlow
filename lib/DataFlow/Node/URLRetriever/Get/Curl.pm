package DataFlow::Node::URLRetriever::Get::Curl;

#ABSTRACT: A HTTP Getter implementation using Curl

use strict;
use warnings;

# VERSION

use Moose::Role;
use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;

