package DataFlow::Util::HTTPGet::Curl;

use strict;
use warnings;

# ABSTRACT: A HTTP Getter implementation using Curl

# VERSION

use Moose::Role;
use LWP::Curl 0.08;

sub _make_obj {
    return LWP::Curl->new;
}

1;

