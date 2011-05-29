
use Test::More tests => 6;

use_ok('DataFlow::Proc::NOP');

my $nop = DataFlow::Proc::NOP->new;
ok($nop);
ok( !defined( $nop->process() ) );
is( ( $nop->process('yadayadayada') )[0], 'yadayadayada' );
is( ( $nop->process(42) )[0],             42 );
is( ( $nop->process( [qw/a b c d e f g h i j/] ) )[0]->[9], 'j' );
