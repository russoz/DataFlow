use Test::More tests => 12;

package Repeat;
use Moose;
extends 'DataFlow::Proc';
has times => ( is => 'ro', isa => 'Int', required => 1 );
has '+p' => (
    default => sub {
        my $self = shift;
        return sub {
            return $_ x $self->times;
        };
    }
);
no Moose;

package main;

use DataFlow;
use DataFlow::Proc;

# tests: 3
my $uc = DataFlow::Proc->new(
    name => 'UpperCase',
    p    => sub { uc }
);
ok($uc);
my $rv = DataFlow::Proc->new(
    name => 'Reverse',
    p    => sub { scalar reverse }
);
ok($rv);
my $flow = DataFlow->new( procs => [ $uc, $rv ] );
ok($flow);

#use Data::Dumper;
#diag( Dumper($flow) );
#diag( Dumper($flow->procs) );

# tests: 2
ok( !defined( $flow->process() ) );

#print STDERR '=' x 70 . "\n";
my $abc = $flow->process('abc');

#use Data::Dumper; diag( 'abc = ' ,$abc );
ok( $abc eq 'CBA' );

# tests: 3
my $rp5 = Repeat->new( times => 5 );
ok($rp5);
my $cc = DataFlow::Proc->new( p => sub { length } );
ok($cc);
my $flow2 = DataFlow->new( procs => [ $rp5, sub { length }, ] );
ok($flow2);

# tests: 2
$flow2->input( 'qwerty', 'yay' );

#use Data::Dumper; diag( Dumper($chain) );
my $thirty = $flow2->output;

#use Data::Dumper; diag( Dumper($thirty) );
ok( $thirty == 30 );

#use Data::Dumper; diag( Dumper($chain2) );
my $fifteen = $flow2->output;

#use Data::Dumper; diag( Dumper($fifteen) );
ok( $fifteen == 15 );

eval {
    my $f =
      DataFlow->new(
        procs => [ { 'testing' => 'a different kind of reference' }, \$fifteen ]
      );
};
ok($@);

eval { my $f = DataFlow->new( procs => [] ); };
ok($@);

