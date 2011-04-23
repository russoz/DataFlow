
use Test::More tests => 9;

BEGIN {
    use_ok('DataFlow::Proc::HTMLFilter');
}

my $fail = eval q{DataFlow::Proc::HTMLFilter->new};
ok($@);

my $filter1 = DataFlow::Proc::HTMLFilter->new( search_xpath => '//td', );
ok($filter1);
ok( !defined( $filter1->process_one() ) );

my $html = <<HTML_END;
<html>
    <body>
        <table>
            <tr>
                <th>A</th>
                <th>B</th>
                <th>C</th>
            </tr>
            <tr>
                <td>a1 yababaga    </td>
                <td>b1 bugalu</td>
                <td>c1 potatoes</td>
            </tr>
        </table>
    </body>
</html>
HTML_END

my @res = $filter1->process_one($html);
is( $res[2], '<td>c1 potatoes</td>' );

my $filter2 = DataFlow::Proc::HTMLFilter->new(
    search_xpath => '//td',
    result_type  => 'VALUE',
);
ok($filter2);

my @res2 = $filter2->process_one($html);
is( $res2[1], 'b1 bugalu' );

my $filter3 = DataFlow::Proc::HTMLFilter->new(
    search_xpath => '//th',
    result_type  => 'VALUE',
    ref_result   => 1,
);
ok($filter3);

my $res3 = ( $filter3->process_one($html) )[0];
is( $res3->[0], 'A' );

# TODO: add tests to check the 'nochomp' option

