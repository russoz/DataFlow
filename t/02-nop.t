
use Test::More tests => 6;

use_ok('DataFlow::Proc::NOP');

my $nop = DataFlow::Proc::NOP->new;
ok($nop);
ok( !defined( $nop->process_one() ) );
ok( $nop->process_one('yadayadayada') eq 'yadayadayada' );
ok( $nop->process_one(42) == 42 );
ok( $nop->process_one( [qw/a b c d e f g h i j/] )->[9] eq 'j' );
