
use Test::More tests => 5;

use_ok('DataFlow::Node::Null');

use DataFlow::Node::Null;

my $null = DataFlow::Node::Null->new;
ok($null);
ok( !defined( $null->process('yadayadayada') ) );
ok( !defined( $null->process(42) ) );
ok( !defined( $null->process( [qw/a b c d e f g h i j/] ) ) );
