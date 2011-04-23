
use Test::More tests => 7;

use_ok('DataFlow::Proc::Null');

my $null = DataFlow::Proc::Null->new;
ok($null);
is( ($null->process_into)[0], 0, 'do not process_into' );
ok( !defined( ($null->process_one('yadayadayada'))[0] ) );
ok( !defined( ($null->process_one(42))[0] ) );
ok( !defined( ($null->process_one( [qw/a b c d e f g h i j/] ))[0] ) );

my $notinto = DataFlow::Proc::Null->new( process_into => 1 );
is( ($notinto->process_into)[0], 0, q{do not allow process_into => 1} );
