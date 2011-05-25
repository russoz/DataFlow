use Test::More tests => 28;

use strict;

use DataFlow;
use DataFlow::Proc;

# each call = 2 tests
sub test_uc_with {
    my $flow = DataFlow->new(@_);
    ok($flow, q{test_uc_wth(}.join(q{,},@_).q{)});
    my @res = $flow->process('abcdef');
    is( $res[0], 'ABCDEF' );
}

my $uc = sub { uc(shift) };
my $proc = DataFlow::Proc->new( p => $uc );
my $flow = DataFlow->new( procs => [$proc] );

# proc
test_uc_with( procs => [$proc] );
test_uc_with( procs => $proc );
test_uc_with( [$proc] );
test_uc_with($proc);

# code
test_uc_with( procs => [$uc] );
test_uc_with( procs => $uc );
test_uc_with( [$uc] );
test_uc_with($uc);

# flow
test_uc_with( procs => [$flow] );
test_uc_with( procs => $flow );
test_uc_with( [$flow] );
test_uc_with($flow);

# each call = 2 tests
sub test_ucf_with {
    my $flow = DataFlow->new(@_);
    ok($flow, q{test_ucf_wth(}.join(q{,},@_).q{)});
    my @res = $flow->process('abcdef');
    is( $res[0], 'Abcdef' );
}

my $ucfirst = sub { ucfirst(shift) };
my @mix = ( $flow, $proc, sub { lc(shift) }, $ucfirst );

# mix
test_ucf_with( procs => [@mix] );
test_ucf_with( [@mix] );

