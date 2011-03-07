use Test::More tests => 7;

use_ok('DataFlow::Node::LiteralData');

eval { $fail = DataFlow::Node::LiteralData->new };
ok($@);

my $node = DataFlow::Node::LiteralData->new( data => 'aaa', );

#use Data::Dumper;
#diag(Dumper( $node ));
#diag(Dumper( $node->output ));
#my $res = $node->output;
#diag( 'res = '.$res );
my $aaa = $node->output;
is( $aaa, 'aaa' );

#ok( $node->output eq 'aaa' );
ok( !( $node->output ) );

eval { $node->input('more input') };
ok( !$@ );
my $empty = $node->output;
ok( !defined($empty) );

my $data = [qw/oh my goodness/];
$node = DataFlow::Node::LiteralData->new( data => $data, );
my $res = $node->output;
is_deeply( $res, $data );

