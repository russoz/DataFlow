package DataFlow::Util::HTTPGet::Curl;

use strict;
use warnings;

# ABSTRACT: A HTTP Getter implementation using Curl
# ENCODING: utf8

# VERSION

use Moose::Role;
use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;

