use Test::More tests => 40;

use strict;

use DataFlow;
use DataFlow::Proc;

# each call = 2 tests
sub test_uc_with {
    my $flow = DataFlow->new(@_);
    ok( $flow, q{test_uc_wth(} . join( q{,}, @_ ) . q{)} );
    my @res = $flow->process('abcdef');
    is( $res[0], 'ABCDEF', '...and returns the right value' );
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

# string
test_uc_with( procs => ['UC'] );
test_uc_with( procs => 'UC' );
test_uc_with( ['UC'] );
test_uc_with('UC');

# each call = 2 tests
sub test_ucf_with {
    my $flow = DataFlow->new(@_);
    ok( $flow, q{test_ucf_wth(} . join( q{,}, @_ ) . q{)} );
    my @res = $flow->process('abcdef');
    is( $res[0], 'Abcdef' );
}

my $ucfirst = sub { ucfirst(shift) };
my @mix = ( $flow, $proc, sub { lc(shift) }, $ucfirst );

# mix
test_ucf_with( procs => [@mix] );
test_ucf_with( [@mix] );
test_ucf_with( procs => [ $flow, $proc, 'UC', sub { lc(shift) }, $ucfirst ] );
test_ucf_with( [ $flow, $proc, 'UC', sub { lc(shift) }, $ucfirst ] );
