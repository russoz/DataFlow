use Test::More tests => 3;

use_ok('DataFlow::Proc::Encoding');
new_ok('DataFlow::Proc::Encoding');

sub test_convert {
    my $test = shift;

    my $e = DataFlow::Proc::Encoding->new(
        input_encoding  => $test->{from}->[0],
        output_encoding => $test->{to}->[0],
    );

    my @res = $e->process_one( $test->{from}->[1] );
    ok( $res[0] eq $test->{to}->[1] );
}

TODO: {
    todo_skip q{Encoding tests unfinished}, 1 unless exists $ENV{TEST_TODO};
    test_convert(
        {
            from => [ 'iso8859-1' => "B\x{736f}cego" ],
            to   => [ 'utf8'      => "B\x{7574}cego" ]
        }
    );
}

