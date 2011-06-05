use Test::More tests => 10;

use DataFlow::Proc;

# tests: 1
my $uc = DataFlow::Proc->new( p => sub { uc }, );
ok($uc);

# tests: 2
my $val = 'yabadabadoo';
is( ( $uc->process($val) )[0], 'YABADABADOO' );
my $res = ( $uc->process( \$val ) )[0];
is( $$res, 'YABADABADOO' );

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
is( ( $uc->process($cref) )[0]->(), 'GGG' );

# do not process_into
#

my $not_into = DataFlow::Proc->new(
    p            => sub { ucfirst },
    process_into => 0,
);
ok($not_into);

my $valnot = 'yabadabadoo';
is( ( $not_into->process($valnot) )[0], 'Yabadabadoo' );

my $copy   = $valnot;
my $resnot = ( $not_into->process( \$copy ) )[0];
is( ref($resnot), 'SCALAR' );
is( $$resnot,     $valnot );

