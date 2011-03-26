
use Test::More tests => 5;

use_ok('DataFlow::Proc::Null');

my $null = DataFlow::Proc::Null->new;
ok($null);
ok( !defined( $null->process_one('yadayadayada') ) );
ok( !defined( $null->process_one(42) ) );
ok( !defined( $null->process_one( [qw/a b c d e f g h i j/] ) ) );
