
use Test::More tests => 5;

use_ok('DataFlow::Node::Null');

use DataFlow::Node::Null;

my $nop = DataFlow::Node::Null->new;
ok($nop);
ok( !defined( $nop->process('yadayadayada') ) );
ok( !defined( $nop->process(42) ) );
ok( !defined( $nop->process( [qw/a b c d e f g h i j/] ) ) );
