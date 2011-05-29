use Test::More tests => 9;

BEGIN { use_ok('DataFlow::Proc'); }

# tests: 2
diag('constructor and basic tests');
my $uc = DataFlow::Proc->new(
    p => sub {
        return eval { uc(shift) };
    }
);
ok($uc);
isa_ok( $uc, 'DataFlow::Proc' );
can_ok( $uc, qw(name deref process_into dump_input dump_output p process) );

is( $uc->p->('iop'), 'IOP' );

# tests: 4
# scalars
diag('scalar params');
ok( !defined( $uc->process() ), 'returns nothing for nothing' );
is( ( $uc->process('aaa') )[0], 'AAA', 'works as it should' );
isnt( ( $uc->process('bbb') )[0], 'bbb', 'indeed works as it should' );
is( ( $uc->process(1) )[0], 1, );

