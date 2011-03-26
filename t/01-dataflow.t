use Test::More tests => 21;

use strict;

BEGIN {
    use_ok('DataFlow');
}

use DataFlow::Proc;

# tests: 3
diag('constructor and basic tests');
my $proc_uc = DataFlow::Proc->new( p => sub { return uc(shift) } );
ok($proc_uc);
is( $proc_uc->p->('iop'), 'IOP' );
my $f = DataFlow->new( procs => [$proc_uc] );
ok($f);

# tests: 4
# scalars
diag('scalar params');
ok( !defined( $f->process() ) );
is( $f->process('aaa'), 'AAA' );
isnt( $f->process('aaa'), 'aaa' );
is( $f->process(1), 1 );

# tests: 13
# array
diag('array params');
my @allyourbase = qw/all your base is belong to us/;

my @r = $f->process(@allyourbase);
is( $r[0], 'ALL' );
is( $r[1], 'YOUR' );
is( $r[2], 'BASE' );
is( $r[3], 'IS' );
is( $r[4], 'BELONG' );
is( $r[5], 'TO' );
is( $r[6], 'US' );
my ( $all, $your, $base ) = $f->process(@allyourbase);
is( $all,  'ALL' );
is( $your, 'YOUR' );
is( $base, 'BASE' );

ok( !defined( $f->output ) );
my $r1 = $f->process(@allyourbase);
ok( !defined( $f->output ) );

$f->flush;
ok( !$f->output );

