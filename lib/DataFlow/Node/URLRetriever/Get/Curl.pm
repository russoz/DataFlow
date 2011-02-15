
package DataFlow::Node::URLRetriever::Get::Curl;

use Moose::Role;

use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;

