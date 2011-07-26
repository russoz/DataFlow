
use Test::More tests => 7;

use_ok('DataFlow::ProcWrapper');

eval { my $fail = DataFlow::ProcWrapper->new };
ok($@);

my $wrapped = DataFlow::ProcWrapper->new( wraps => 'UC' );
ok($wrapped);
eval { my @fail = $wrapped->process( 'abc' ) };
ok($@);
my @res = $wrapped->process( 'abc', 1 );
is( scalar( @res ), 1 );
isnt( $res[0], 'ABC' );
is( $res[0]->get_data( 'default' ), 'ABC' );

# non-raw input tests



# channel tests



# multiple responses tests


