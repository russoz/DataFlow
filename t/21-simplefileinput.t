use Test::More tests => 17;

use_ok('DataFlow::Node::SimpleFileInput');
new_ok('DataFlow::Node::SimpleFileInput');

my $data =
  DataFlow::Node::SimpleFileInput->new(
    initial_data => ['./examples/file.test'] );

#use Data::Dumper;
#diag(Dumper( $data ));
#diag(Dumper( $data->output ));
#my $res = $data->output;
#diag( 'res = '.$res );
ok( $data->output eq 'linha 1' );
ok( $data->output eq 'linha 2' );
ok( $data->output eq 'linha 3' );
ok( $data->output eq 'linha 4' );
ok( $data->output eq 'linha 5' );
ok( $data->output eq 'linha 6' );
ok( $data->output eq 'linha 7' );

ok( !defined( $data->output ) );

my $data2 = DataFlow::Node::SimpleFileInput->new(
    initial_data => ['./examples/file.test'],
    do_slurp     => 1,
);
my $res2 = $data2->output;

#use Data::Dumper; print STDERR 'slurpy '.Dumper($res2);
ok( $res2->[0] eq 'linha 1' );
ok( $res2->[1] eq 'linha 2' );
ok( $res2->[2] eq 'linha 3' );
ok( $res2->[3] eq 'linha 4' );
ok( $res2->[4] eq 'linha 5' );
ok( $res2->[5] eq 'linha 6' );
ok( $res2->[6] eq 'linha 7' );
