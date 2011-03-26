
use Test::More tests => 3;

use strict;

use_ok('DataFlow::Util::HTTPGet');

use DataFlow::Util::HTTPGet;

my $get = DataFlow::Util::HTTPGet->new;
ok($get);

my $html = $get->get(q{http://www.kernel.org/});

#diag(q{html = } . $html);
ok($html);

1;

