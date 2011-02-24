package DataFlow::Node::URLRetriever::Get::Curl;

use strict;
use warnings;

# VERSION

use Moose::Role;

use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;

