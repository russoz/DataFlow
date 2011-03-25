package DataFlow;

use strict;
use warnings;

# ABSTRACT: A framework for dataflow processing
# ENCODING: utf8

# VERSION

use Moose;
use Moose::Util::TypeConstraints 1.01;

use Scalar::Util qw/looks_like_number/;
use Queue::Base 2.1;
use DataFlow::Proc;

# subtypes
subtype 'ProcessorChain' => as 'ArrayRef[DataFlow::Proc]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorChain' => from 'ArrayRef[Ref]' => via {
    [ map { ref($_) eq 'CODE' ? DataFlow::Proc->new( p => $_ ) : $_ } @{$_} ];
};
coerce 'ProcessorChain' => from 'DataFlow::Proc' => via { [$_] };
coerce 'ProcessorChain' => from 'CodeRef' => via {
    [ DataFlow::Proc->new( p => $_ ) ];
};

# attributes
has 'name' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'auto_process' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 1,
);

has 'procs' => (
    'is'       => 'ro',
    'isa'      => 'ProcessorChain',
    'required' => 1,
    'coerce'   => 1,
);

has '_queues' => (
    'is'      => 'ro',
    'isa'     => 'ArrayRef[Queue::Base]',
    'lazy'    => 1,
    'default' => sub { return _make_queues( shift->procs ); },
    'handles' => {
        '_firstq'         => sub { return shift->_queues->[0] },
        'has_queued_data' => sub {
            return _count_queued_items( shift->_queues );
        },
    },
);

has '_lastq' => (
    'is'      => 'ro',
    'isa'     => 'Queue::Base',
    'lazy'    => 1,
    'default' => sub { return Queue::Base->new },
);

# functions
sub _count_queued_items {
    my $q     = shift;
    my $count = 0;

    #use Data::Dumper; print 'COUNT: '.Dumper($q);
    map { $count = $count + $_->size } @{$q};

    #print 'COUNT = ' . $count . "\n";
    return $count;
}

sub _process_queues {
    my ( $p, $inputq, $outputq ) = @_;

    my $item = $inputq->remove;
    my @res  = $p->process_one($item);
    $outputq->add(@res);
    return;
}

sub _make_queues {
    my $procs  = shift;
    my @queues = map { Queue::Base->new() } @{$procs};
    return [@queues];
}

sub _reduce {
    my ( $p, @q ) = @_;
    map { _process_queues( $p->[$_], $q[$_], $q[ $_ + 1 ] ) } ( 0 .. $#q - 1 );
    return;
}

# methods
sub clone {
    my $self = shift;
    return DataFlow->new( procs => $self->procs );
}

sub input {
    my ( $self, @args ) = @_;
    $self->_firstq->add(@args);
    return;
}

sub process_input {
    my $self = shift;
	my @q = ( @{ $self->_queues }, $self->_lastq );
    _reduce( $self->procs, @q );
    return;
}

sub output {
    my $self = shift;

    $self->process_input if ( $self->_lastq->empty && $self->auto_process );

    #use Data::Dumper; warn 'output self = ' .Dumper($self);
    return wantarray ? $self->_lastq->remove_all : $self->_lastq->remove;
}

sub flush {
    my $self = shift;
    while ( $self->has_queued_data ) {

        #use Data::Dumper; print "FLUSH ".Dumper($self);
        $self->process_input;
    }
    return $self->output;
}

sub process {
    my ( $self, @args ) = @_;

    my $flow = $self->clone();
    $flow->input(@args);
    return $flow->flush;
}

__PACKAGE__->meta->make_immutable;
no Moose::Util::TypeConstraints;
no Moose;

1;

=pod

=head1 SYNOPSIS

use DataFlow;

	my $flow = DataFlow->new(
		DataFlow::Proc->new( p => sub { do this thing } ),
		sub { ... do something },
		sub { ... do something else },
	);

	$flow->input( <some input> );
	my $output = $flow->output();

	my $output = $flow->output( <some other input> );

=head1 DESCRIPTION

A C<DataFlow> object is able to accept data, feed it into an array of
processors (L<DataFlow::Proc> objects), and return the result(s) back to the
caller.

=head1 HISTORY

This is a framework for data flow processing. It started as a spinoff project
from the L<OpenData-BR|http://www.opendatabr.org/> initiative.

As of now (Mar, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and also
the documentation for L<DataFlow::Node> and L<DataFlow::Chain>, to start with.

An article has been recently written in Brazilian Portuguese about this
framework, per the São Paulo Perl Mongers "Equinócio" (Equinox) virtual event.
Although an English version of the article in in the plans, you can figure
a good deal out of the original one at

L<http://sao-paulo.pm.org/equinocio/2011/mar/5>

B<UPDATE:> L<DataFlow> is a fast-evolving project, and this article, as
it was published there, refers to versions 0.91.x of the framework. There has
been a big refactor since then and, although the concept remains the same,
the programming interface has been changed violently.

Any doubts, feel free to get in touch.

=head1 ATTRIBUTES

=head2 name

[Str] A descriptive name for the dataflow. (OPTIONAL)

=head2 auto_process

[Bool] If there is data available in the output queue, and one calls the
C<output()> method, this attribute will flag whether the dataflow should
attempt to automatically process queued data. (DEFAULT: true)

=head2 procs

[ArrayRef[DataFlow::Proc]] The list of processors that make this DataFlow.
Optionally, you may pass CodeRefs that will be automatically converted to
L<DataFlow::Proc> objects. (REQUIRED)

=head1 METHODS

=head2 has_queued_data

Returns true if the dataflow contains any queued data within.

=head2 clone

Returns another instance of a C<DataFlow> using the same array of processors.

=head2 input

Accepts input data for the node. It will gladly accept anything passed as
parameters. However, it must be noticed that it will not be able to make a
distinction between arrays and hashes. Both forms below will render the exact
same results:

	$flow->input( qw/all the simple things/ );
	$flow->input( all => 'the', simple => 'things' );

If you do want to handle arrays and hashes differently, we strongly suggest
that you use references:

	$node->input( [ qw/all the simple things/ ] );
	$node->input( { all => the, simple => 'things' } );

Processors with C<process_into> enabled (true by default) will process the
items inside an array reference, and the values (not the keys) inside a hash
reference.

=head2 process_input

Processes items in the array of queues and place at least one item in the
output (last) queue. One will typically call this to flush out some unwanted
data and/or if C<auto_process> has been disabled.

=head2 output

Fetches data from the node. If called in scalar context it will return one
processed item from the flow. If called in list context it will return all the
elements in the last queue.

=head2 flush

Flushes all the data through the dataflow, and returns the complete result set.

=head2 process

Immediately processes a bunch of data, without touching the object queues. It
will process all the provided data and return the complete result set for it.

=cut

