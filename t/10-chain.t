
use Test::More tests => 12;

package Repeat;
use Moose;
extends 'DataFlow::Node';
has times => ( is => 'ro', isa => 'Int', required => 1 );
has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $item ) = @_;
            return "$item" x $self->times;
        };
    }
);

package main;

use DataFlow::Node;
use DataFlow::Chain;
use common::sense;

# tests: 3
my $uc = DataFlow::Node->new(
    name         => 'UpperCase',
    process_item => sub { shift; return uc(shift) }
);
ok($uc);
my $rv = DataFlow::Node->new(
    name         => 'Reverse',
    process_item => sub { shift; return scalar reverse $_[0]; }
);
ok($rv);
my $chain = DataFlow::Chain->new( links => [ $uc, $rv ] );
ok($chain);

#use Data::Dumper;
#diag( Dumper($chain) );
#diag( Dumper($chain->chain) );

# tests: 2
ok( !defined( $chain->process() ) );

#print STDERR '=' x 70 . "\n";
my $abc = $chain->process('abc');

#use Data::Dumper; diag( 'abc = ' ,$abc );
ok( $abc eq 'CBA' );

# tests: 3
my $rp5 = Repeat->new( times => 5 );
ok($rp5);
my $cc =
  DataFlow::Node->new( process_item => sub { shift; return length(shift) } );
ok($cc);
my $chain2 = DataFlow::Chain->new( links => [ $rp5, $cc ] );
ok($chain2);

# tests: 2
$chain2->input( 'qwerty', 'yay' );

#use Data::Dumper; diag( Dumper($chain) );
my $thirty = $chain2->output;

#use Data::Dumper; diag( Dumper($thirty) );
ok( $thirty == 30 );

#use Data::Dumper; diag( Dumper($chain2) );
my $fifteen = $chain2->output;

#use Data::Dumper; diag( Dumper($fifteen) );
ok( $fifteen == 15 );

my $chain3 = DataFlow::Chain->new( links => [] );
ok($chain3);

eval { $chain3->process('some text') };
ok( $@, $@ );

