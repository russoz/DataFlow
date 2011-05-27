use Test::More tests => 6;

use DataFlow::Proc;

my $uc = sub { uc(shift) };

sub test_uc_with {
    my @args = @_;
    my $proc = DataFlow::Proc->new(@args);
    ok($proc);
    my @res = $proc->p->('abcdef');
    is( $res[0], 'ABCDEF' );
}

test_uc_with( p => $uc );
test_uc_with( p => DataFlow::Proc->new( p => $uc ) );
use DataFlow;
my $d = DataFlow->new( procs => [ DataFlow::Proc->new( p => $uc ) ] );
test_uc_with( p => $d );

