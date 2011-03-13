use Test::More tests => 6;

use_ok('DataFlow::Proc::LiteralData');

eval { $fail = DataFlow::Proc::LiteralData->new };
ok($@);

#use Data::Dumper;
#diag(Dumper( $node ));
#diag(Dumper( $node->output ));
#my $res = $node->output;
#diag( 'res = '.$res );
my $aaa = DataFlow::Proc::LiteralData->new('aaa');
is( $aaa->process_one(), 'aaa' );

#ok( $node->output eq 'aaa' );
ok( !defined( $aaa->process_one() ) );
ok( !defined( $aaa->process_one('more input') ) );

my $data = [qw/oh my goodness/];
my $ref  = DataFlow::Proc::LiteralData->new($data);
my $res  = $ref->process_one();
is_deeply( $res, $data );

# test with 'infinite' option enabled
# my $bbb = DataFlow::Proc::LiteralData->new(
