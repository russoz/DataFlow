use Test::More tests => 2;

use DataFlow;

my $flow = DataFlow->new( [ sub { uc(shift) } ] );
ok( $flow, 'Can construct a dataflow from a bare sub' );
is( $flow->process('aaa'), 'AAA', 'and it provides the correct result' );

