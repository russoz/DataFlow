
use Test::More tests => 3;

use strict;

use_ok('DataFlow::Node::URLRetriever::Get');

use DataFlow::Node::URLRetriever::Get;

my $get = DataFlow::Node::URLRetriever::Get->new;
ok($get);

my $html = $get->get(q{http://www.kernel.org/});

#diag(q{html = } . $html);
ok($html);

1;

