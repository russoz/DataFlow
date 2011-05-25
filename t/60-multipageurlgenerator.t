
use Test::More tests => 4;

BEGIN {
    use_ok('DataFlow::Proc::MultiPageURLGenerator');
}

eval { $m = DataFlow::Proc::MultiPageURLGenerator->new };
ok( $@, 'Has required parameters' );

$m =
  DataFlow::Proc::MultiPageURLGenerator->new(
    make_page_url => sub { $_[1] . '?page=' . $_[2] }, );
ok($m);

eval { $m->last_page };
ok( $@, q{Must pass 'last_page' or 'produce_last_page'} );
