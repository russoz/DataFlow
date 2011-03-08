use Test::More tests => 9;

use DataFlow::Node;
use common::sense;

# tests: 1
my $uc =
  DataFlow::Node->new( process_item => sub { shift; return uc(shift) }, );
ok($uc);

# tests: 2
my $val = 'yabadabadoo';
ok( $uc->process($val) eq 'YABADABADOO' );
my $res = $uc->process( \$val );
ok( $$res eq 'YABADABADOO' );

# tests: 1
my $aref = [qw/ww xx yy zz/];
is_deeply( $uc->process($aref), [qw/WW XX YY ZZ/] );

# tests: 1
my $href = {
    11 => 'aa',
    22 => 'bb',
    33 => 'cc',
    44 => 'dd',
};
is_deeply(
    $uc->process($href),
    {
        11 => 'AA',
        22 => 'BB',
        33 => 'CC',
        44 => 'DD',
    }
);

# tests: 1
my $cref = sub { return 'ggg' };
ok( $uc->process($cref)->() eq 'GGG' );

# do not process_into
#

my $not_into = DataFlow::Node->new(
    process_item => sub { shift; return uc(shift) },
    process_into => 0,
);
ok($not_into);

my $valnot = 'yabadabadoo';
ok( $not_into->process($valnot) eq 'YABADABADOO' );

my $refnot = \$valnot;
my $resnot = $not_into->process($refnot);
isnt( $resnot, $refnot );

