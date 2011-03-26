
use Test::More tests => 4;

use_ok('DataFlow::Proc::Dumper');

my $dump = DataFlow::Proc::Dumper->new;
ok($dump);
is( $dump->process_into, 0, 'do not process_into' );

my $notinto = DataFlow::Proc::Dumper->new( process_into => 1 );
is( $notinto->process_into, 0, q{do not allow process_into => 1} );
