use Test::More tests => 11;

use strict;

use DataFlow::Proc;

# tests: 2
my $n = DataFlow::Proc->new(
    deref => 1,
    p     => sub { return ucfirst(shift); },
);
ok($n);
is( $n->p->('iop'), 'Iop' );

# tests: 2
# scalars
ok( !defined( $n->process() ) );
ok( ( $n->process('aaa') )[0] eq 'Aaa' );

# tests: 1
# scalar refs
my $val = 'babaloo';
ok( ( $n->process( \$val ) )[0] eq 'Babaloo' );

# tests: 2
# array refs
my @res_aref = $n->process( [qw/aa bb cc dd ee ff gg hh ii jj/] );
is( $res_aref[0], 'Aa' );
is( $res_aref[9], 'Jj' );

# tests: 4
# hash refs
my %res_href =
  $n->process( { ii => 'jj', kk => 'll', mm => 'nn', oo => 'pp' } );
is( $res_href{'ii'}, 'Jj' );
is( $res_href{'kk'}, 'Ll' );
is( $res_href{'mm'}, 'Nn' );
is( $res_href{'oo'}, 'Pp' );

