use Test::More tests => 36;

use strict;

use DataFlow::Node;

# tests: 2
diag('constructor and basic tests');
my $uc = DataFlow::Node->new(
    process_item => sub {
        shift;
        return eval { uc(shift) };
    }
);
ok($uc);
is( $uc->process_item->( $uc, 'iop' ), 'IOP' );

# tests: 4
# scalars
diag('scalar params');
ok( !defined( $uc->process() ) );
is( $uc->process('aaa'), 'AAA' );
isnt( $uc->process('aaa'), 'aaa' );
is( $uc->process(1), 1 );

# tests: 13
# array
diag('array params');
my @r = $uc->process(qw/all your base is belong to us/);
is( $r[0], 'ALL' );
is( $r[1], 'YOUR' );
is( $r[2], 'BASE' );
is( $r[3], 'IS' );
is( $r[4], 'BELONG' );
is( $r[5], 'TO' );
is( $r[6], 'US' );
my ( $all, $your, $base ) = $uc->process(qw/all your base is belong to us/);
is( $all,  'ALL' );
is( $your, 'YOUR' );
is( $base, 'BASE' );

ok( !defined( $uc->output ) );
my $r1 = $uc->process(qw/all your base is belong to us/);
is( $uc->output, 'YOUR' );
is( $uc->output, 'BASE' );

$uc->flush;
ok( !$uc->output );

$uc->input(qw/aa bb cc dd ee ff gg hh ii jj/);

# returns qw/AA BB CC/
my @r3 = $uc->output(3);
is( scalar(@r3), 3 );
is( $r3[0],      'AA' );
is( $r3[1],      'BB' );
is( $r3[2],      'CC' );

# returns qw/DD/ - output queue is empty, so takes on item from input queue
@r3 = $uc->output;
is( scalar(@r3), 1 );
is( $r3[0],      'DD' );

# returns qw/EE/ - requested one, got one
@r3 = $uc->output(1);
is( scalar(@r3), 1 );
is( $r3[0],      'EE' );

# fail, must be a number
eval { @r3 = $uc->output('pumpkin') };
ok($@);

# fail, must be positive
eval { @r3 = $uc->output(-1) };
ok($@);

# processes 2 items from input to output
$uc->process_input;
$uc->process_input;

# then ask for 5 items - the remaining 3 should be automatically processed
# returns qw/FF GG HH II JJ/
@r3 = $uc->output(5);
is( scalar(@r3), 5 );
is( $r3[0],      'FF' );
is( $r3[1],      'GG' );
is( $r3[2],      'HH' );
is( $r3[3],      'II' );
is( $r3[4],      'JJ' );

