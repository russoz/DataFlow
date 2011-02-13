
use Test::More tests => 6;

use_ok('DataFlow::Node::NOP');

use DataFlow::Node::NOP;

my $nop = DataFlow::Node::NOP->new;
ok($nop);
ok( !defined( $nop->process() ) );
ok( $nop->process('yadayadayada') eq 'yadayadayada' );
ok( $nop->process(42) == 42 );
ok( $nop->process( [qw/a b c d e f g h i j/] )->[9] eq 'j' );
