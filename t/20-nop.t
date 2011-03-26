
use Test::More tests => 6;

use_ok('DataFlow::Proc::NOP');

my $nop = DataFlow::Proc::NOP->new;
ok($nop);
ok( !defined( $nop->process_one() ) );
is( $nop->process_one('yadayadayada'), 'yadayadayada' );
is( $nop->process_one(42),             42 );
is( $nop->process_one( [qw/a b c d e f g h i j/] )->[9], 'j' );
