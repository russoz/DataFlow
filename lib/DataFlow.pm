package DataFlow;

use strict;
use warnings;

# ABSTRACT: A framework for dataflow processing

# VERSION

use Moose;
with 'DataFlow::Role::Processor';
with 'DataFlow::Role::Dumper';

use DataFlow::Types qw(ProcessorChain);

use namespace::autoclean;
use Queue::Base 2.1;

with 'MooseX::OneArgNew' => { 'type' => 'Str',      'init_arg' => 'procs', };
with 'MooseX::OneArgNew' => { 'type' => 'ArrayRef', 'init_arg' => 'procs', };
with 'MooseX::OneArgNew' => { 'type' => 'CodeRef',  'init_arg' => 'procs', };
with 'MooseX::OneArgNew' => { 'type' => 'DataFlow', 'init_arg' => 'procs', };
with 'MooseX::OneArgNew' =>
  { 'type' => 'DataFlow::Proc', 'init_arg' => 'procs', };

# attributes
has 'name' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_name',
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
    'default' => sub { return shift->_make_queues(); },
    'handles' => {
        '_firstq' => sub { return shift->_queues->[0] },
        'has_queued_data' =>
          sub { return _count_queued_items( shift->_queues ) },
        '_make_queues' => sub {
            return [ map { Queue::Base->new() } @{ shift->procs } ];
        },
    },
);

has '_lastq' => (
    'is'      => 'ro',
    'isa'     => 'Queue::Base',
    'lazy'    => 1,
    'default' => sub { return Queue::Base->new },
);

has 'dump_input' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the input load to STDERR',
);

has 'dump_output' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the output load to STDERR',
);

# functions
sub _count_queued_items {
    my $q     = shift;
    my $count = 0;

    map { $count = $count + $_->size } @{$q};

    return $count;
}

sub _process_queues {
    my ( $proc, $inputq, $outputq ) = @_;

    my $item = $inputq->remove;
    my @res  = $proc->process($item);
    $outputq->add(@res);
    return;
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
    $self->prefix_dumper( $self->has_name ? $self->name . ' <<' : '<<', @args )
      if $self->dump_input;

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
    my @res = wantarray ? $self->_lastq->remove_all : $self->_lastq->remove;
    $self->prefix_dumper( $self->has_name ? $self->name . ' >>' : '>>', @res )
      if $self->dump_output;
    return wantarray ? @res : $res[0];
}

sub flush {
    my $self = shift;
    while ( $self->has_queued_data ) {
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

1;

=pod

=head1 SYNOPSIS

use DataFlow;

	my $flow = DataFlow->new(
		procs => [
			DataFlow::Proc->new( p => sub { do this thing } ),
			sub { ... do something },
			sub { ... do something else },
			CSV => {
				direction     => 'TO_CSV',
				text_csv_opts => { binary => 1 },
			},
		]
	);

	$flow->input( <some input> );
	my $output = $flow->output();

	my $output = $flow->output( <some other input> );

=head1 DESCRIPTION

A C<DataFlow> object is able to accept data, feed it into an array of
processors (L<DataFlow::Proc> objects), and return the result(s) back to the
caller.

=attr name

[Str] A descriptive name for the dataflow. (OPTIONAL)

=attr auto_process

[Bool] If there is data available in the output queue, and one calls the
C<output()> method, this attribute will flag whether the dataflow should
attempt to automatically process queued data. (DEFAULT: true)

=attr procs

[ArrayRef[DataFlow::Proc]] The list of processors that make this DataFlow.
Optionally, you may pass CodeRefs that will be automatically converted to
L<DataFlow::Proc> objects. (REQUIRED)

The C<procs> parameter will accept some variations in its value. Any
C<ArrayRef> passed will be parsed, and additionaly to plain
C<DataFlow::Proc> objects, it will accept: C<DataFlow> objects (so one can
nest flows), code references (C<sub{}> blocks) and plain text strings.

The text string form is treatedi, for a given "TEXT", in the following order:
if it contains '::' then DataFlow will try to use a class named "TEXT";
it that doesn't work (or if it doesn't contain '::'), DataFlow will try to load
a class named 'DataFlow::Proc::TEXT'; if that fails, it tries one last time to
load a class named 'TEXT'. If that last try doesn't work, it dies.

Additionally, one may pass any of these forms as a single argument to the
constructor C<new>, plus a single C<DataFlow>, or C<DataFlow:Proc> or string.

=method has_queued_data

Returns true if the dataflow contains any queued data within.

=method clone

Returns another instance of a C<DataFlow> using the same array of processors.

=method input

Accepts input data for the data flow. It will gladly accept anything passed as
parameters. However, it must be noticed that it will not be able to make a
distinction between arrays and hashes. Both forms below will render the exact
same results:

	$flow->input( qw/all the simple things/ );
	$flow->input( all => 'the', simple => 'things' );

If you do want to handle arrays and hashes differently, we strongly suggest
that you use references:

	$flow->input( [ qw/all the simple things/ ] );
	$flow->input( { all => the, simple => 'things' } );

Processors with C<process_into> enabled (true by default) will process the
items inside an array reference, and the values (not the keys) inside a hash
reference.

=method process_input

Processes items in the array of queues and place at least one item in the
output (last) queue. One will typically call this to flush out some unwanted
data and/or if C<auto_process> has been disabled.

=method output

Fetches data from the data flow. If called in scalar context it will return
one processed item from the flow. If called in list context it will return all
the elements in the last queue.

=method flush

Flushes all the data through the dataflow, and returns the complete result set.

=method process

Immediately processes a bunch of data, without touching the object queues. It
will process all the provided data and return the complete result set for it.

=head1 HISTORY

This is a framework for data flow processing. It started as a spinoff project
from the L<OpenData-BR|http://www.opendatabr.org/> initiative.

As of now (Mar, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and the
documentation of L<DataFlow::Proc>, to start with.

An article has been recently written in Brazilian Portuguese about this
framework, per the São Paulo Perl Mongers "Equinócio" (Equinox) virtual event.
Although an English version of the article in in the plans, you can figure
a good deal out of the original one at

L<http://sao-paulo.pm.org/equinocio/2011/mar/5>

B<UPDATE:> L<DataFlow> is a fast-evolving project, and this article, as
it was published there, refers to versions 0.91.x of the framework. There has
been a big refactor since then and, although the concept remains the same,
since version 0.950000 the programming interface has been changed violently.

Any doubts, feel free to get in touch.

=cut

