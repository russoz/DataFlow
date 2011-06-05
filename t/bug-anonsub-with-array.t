use Test::More tests => 16;

use strict;

use DataFlow;
use DataFlow::Proc;
use aliased 'DataFlow::Proc::NOP';

my $sub = sub {
    s/^\s*//;
    s/\s*$//;
    return $_;
};

my $flow1 = DataFlow->new( procs => [ NOP->new(), $sub, ], );
ok($flow1);

my $flow2 =
  DataFlow->new( procs => [ NOP->new(), DataFlow::Proc->new( p => $sub ), ], );
ok($flow2);

my @data = (
    q{This is a test for a nasty bug      },
    q{  inserting some leading and trailing spaces },
    q{  to make sure it works},
);

$flow1->input(@data);
my @res1 = $flow1->flush;
is( $res1[0], q{This is a test for a nasty bug} );
is( $res1[1], q{inserting some leading and trailing spaces} );
is( $res1[2], q{to make sure it works} );

$flow2->input(@data);
my @res2 = $flow2->flush;
is( $res2[0], q{This is a test for a nasty bug} );
is( $res2[1], q{inserting some leading and trailing spaces} );
is( $res2[2], q{to make sure it works} );

is_deeply( \@res1, \@res2 );

$flow1->input( [@data] );
@res1 = $flow1->flush;
is( $res1[0]->[0], q{This is a test for a nasty bug} );
is( $res1[0]->[1], q{inserting some leading and trailing spaces} );
is( $res1[0]->[2], q{to make sure it works} );

$flow2->input( [@data] );
@res2 = $flow2->flush;
is( $res2[0]->[0], q{This is a test for a nasty bug} );
is( $res2[0]->[1], q{inserting some leading and trailing spaces} );
is( $res2[0]->[2], q{to make sure it works} );

is_deeply( \@res1, \@res2 );

