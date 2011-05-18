
use Test::More tests => 3;

use strict;

use_ok('DataFlow::Util::HTTPGet');

use DataFlow::Util::HTTPGet;

my $get = DataFlow::Util::HTTPGet->new;
ok($get);

SKIP: {
    diag(q{Skipping HTTP GET test, set HAS_NET=1 to enable it});
    skip q{Skipping HTTP GET test, set HAS_NET=1 to enable it}, 1
      unless exists $ENV{HAS_NET} && $ENV{HAS_NET} eq q{1};
    my $html = $get->get(q{http://www.kernel.org/});

    #diag(q{html = } . $html);
    ok($html);
}

1;

