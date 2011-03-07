package DataFlow::Node;

#ABSTRACT: A generic processing node in a data flow

use strict;
use warnings;

# VERSION

use Moose;

use Scalar::Util qw/blessed reftype/;
use Queue::Base;

has name => (
    is  => 'ro',
    isa => 'Str',
);

has deref => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => 0,
);

has process_into => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
    lazy    => 1,
);

has auto_process => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => 1,
);

has initial_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    trigger => sub {
        my ( $self, $new ) = @_;
        $self->input( @{$new} );
    },
);

has _dumper => (
    is      => 'ro',
    isa     => 'CodeRef',
    lazy    => 1,
    default => sub {
        use Data::Dumper;
        return sub {
            return Dumper(@_);
        };
    },
    handles => {
        prefix_dumper => sub {
            my ( $self, $prefix, @args ) = @_;
            print STDERR $prefix;
            if (@args) {
                print STDERR ' ' . $self->_dumper->(@args);
            }
            else {
                print STDERR "\n";
            }
        },
        raw_dumper => sub {
            my $self = shift;
            print STDERR $self->_dumper->(@_);
        },
    },
);

has dump_input => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => 0,
);

has dump_output => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => 0,
);

has process_item => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
);

##############################################################################
# node input queue

has 'inputq' => (
    is      => 'ro',
    isa     => 'Queue::Base',
    default => sub { Queue::Base->new },
    handles => {
        _add_input => 'add',
        input      => sub { my $self = shift; return $self->_add_input(@_); },
        _dequeue_input => sub { return shift->inputq->remove(1); },
        clear_input    => 'clear',
        has_input      => sub { return !shift->inputq->empty; },
    },
);

before '_add_input' => sub {
    my $self = shift;
    return unless @_;
    $self->prefix_dumper( '>>>', @_ ) if $self->dump_input;
};

sub process_input {
    my $self = shift;
    return unless $self->has_input;

    my $item = $self->_dequeue_input();
    $self->_add_output( $self->_handle_list($item) );

    #use Data::Dumper; warn 'process_input :: self :: after = ' . Dumper($self);
    return;
}

##############################################################################
# node output queue

has 'outputq' => (
    is      => 'ro',
    isa     => 'Queue::Base',
    default => sub { Queue::Base->new },
    handles => {
        _add_output     => 'add',
        _dequeue_output => sub {
            my $self = shift;
            return
              wantarray ? $self->outputq->remove_all : $self->outputq->remove;
        },
        has_output => sub {
            return 0 < shift->outputq->size;
        },
    },
);

before '_add_output' => sub {
    my $self = shift;
    return unless @_;
    $self->prefix_dumper( '<<<', @_ ) if $self->dump_output;
};

sub output {
    my $self = shift;
	my $num = shift;

	$self->process_input if ($self->outputq->empty && $self->auto_process);

	return $self->outputq->remove unless wantarray;

	if( defined($num) ) {
		if ( $self->auto_process ) {
			while( $self->outputq->size < $num && $self->has_input ) {
				$self->process_input;
			}
		}
		return $self->outputq->remove($num);
    }

    #use Data::Dumper; warn 'output self = ' .Dumper($self);
    return $self->outputq->remove_all;
}

sub flush {
    my $self = shift;
    $self->process_input;
    while ( $self->output ) { };    #empty
    return;
}

##############################################################################

sub has_queued_data {
    my $self = shift;
    return ( $self->has_input || $self->has_output );
}

sub process {
    my ( $self, @args ) = @_;
    return unless @args;
    foreach (@args) {
        $self->input($_);
        $self->process_input;
    }
    return wantarray ? $self->output : scalar $self->output;
}

##############################################################################
# node error queue

has '_errorq' => (
    is      => 'ro',
    isa     => 'Queue::Base',
    lazy    => 1,
    default => sub { Queue::Base->new },
    handles => {
        _enqueue_error  => 'add',
        _is_error_empty => 'empty',
        _dequeue_error  => sub {
            my $self = shift;
            return
              wantarray ? $self->errorq->remove_all : $self->errorq->remove;
        },
        flush_error => 'clear',
        clear_error => 'clear',
    },
);

sub get_error {
    my $self = shift;
    return $self->_dequeue_error;
}

##############################################################################
# code to handle different types of input
#   ex: array-refs, hash-refs, code-refs, etc...

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return 'SVALUE' unless $r;
    return 'OBJECT' if blessed($p);
    return $r;
}

sub _handle_list {
    my ( $self, @args ) = @_;
    my @result = ();

    #use Data::Dumper; warn '_handle_list(params) = '.Dumper(@_);
    foreach my $item (@args) {
        my $type = _param_type($item);
        $self->confess('There is no handler for this parameter type!')
          unless exists $self->_handlers->{$type};
        push @result, $self->_handlers->{$type}->( $self, $item );
    }
    return @result;
}

##############################################################################
#
#  _handlers
#
#  _handlers is a hash reference, with reference types (and some other special
#  strings) as keys, and code references (a.k.a. handlers) as values.
#
#  For each key, a handler will be defined taking into account whether this
#  node has process_into == 1 and/or deref == 1.
#

has '_handlers' => (
    is      => 'ro',
    isa     => 'HashRef[CodeRef]',
    lazy    => 1,
    default => sub {
        my $me           = shift;
        my $type_handler = {
            'SVALUE' => \&_handle_svalue,
            'OBJECT' => \&_handle_svalue,
            'SCALAR' => $me->process_into ? \&_handle_scalar_ref
            : \&_handle_svalue,
            'ARRAY' => $me->process_into ? \&_handle_array_ref
            : \&_handle_svalue,
            'HASH' => $me->process_into ? \&_handle_hash_ref : \&_handle_svalue,
            'CODE' => $me->process_into ? \&_handle_code_ref : \&_handle_svalue,
        };
        return $type_handler unless $me->deref;

        return {
            'SVALUE' => sub { $type_handler->{'SVALUE'}->(@_) },
            'OBJECT' => sub { $type_handler->{'OBJECT'}->(@_) },
            'SCALAR' => sub { ${ $type_handler->{'SCALAR'}->(@_) } },
            'ARRAY'  => sub { @{ $type_handler->{'ARRAY'}->(@_) } },
            'HASH'   => sub { %{ $type_handler->{'HASH'}->(@_) } },
            'CODE'   => sub { $type_handler->{'CODE'}->(@_)->() },
        };
    },
);

sub _handle_svalue {
    my ( $self, $item ) = @_;
    return $self->process_item->( $self, $item );
}

sub _handle_scalar_ref {
    my ( $self, $item ) = @_;
    my $r = $self->process_item->( $self, $$item );
    return \$r;
}

sub _handle_array_ref {
    my ( $self, $item ) = @_;

    #use Data::Dumper; warn 'handle_array_ref :: item = ' . Dumper($item);
    my @r = map { $self->process_item->( $self, $_ ) } @{$item};
    return [@r];
}

sub _handle_hash_ref {
    my ( $self, $item ) = @_;
    my %r = map { $_ => $self->process_item->( $self, $item->{$_} ) }
      keys %{$item};
    return {%r};
}

sub _handle_code_ref {
    my ( $self, $item ) = @_;
    return sub { $self->process_item->( $self, $item->() ) };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Node;

    my $uc = DataFlow::Node->new(
        process_item => sub {
            shift; return uc(shift);
        }
    );

    my @res = $uc->process( qw/god save the queen/ );
    # @res == qw/GOD SAVE THE QUEEN/

    # or, in two steps:
    $uc->input( qw/dont panic/ );
    my @cool = $uc->output;
    # @cool == qw/DONT PANIC/

Or

    my $ucd = UC->new(
        process_into => 1,
        process_item => sub {
            shift; return uc(shift);
        }
    );

    $ucd->input( [qw/aaa bbb ccc/] );
    $item = $ucd->output;
    # $item == [ 'AAA', 'BBB', 'CCC' ]

    $ucd->input(
        {   a => 'aaa',
            b => 'bbb } );

    $item = $ucd->output;
    # $item == { a => ' AAA ', b => ' BBB ' }

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a step in a data-flow.
It attemps to be as generic and unassuming as possible, in order to provide
flexibility for implementors to make their own nodes as they see fit.

An object of the type C<DataFlow::Node> does three things:
accepts some data as input,
processes that data,
provides the transformed data as output.

The methods C<input> and C<output> provide the obvious functionality,
while attempting to preserve the input data structure.
The convenience method C<process()> will pump its parameters
into C<< $self->input() >> and immediately
return the result of C<< $self->output() >>.

A node will only be useful if, naturally,
it performs some sort of transformation or processing on the input data.
Thus, objects of the type C<DataFlow::Node> B<must> provide
the code reference named C<process_item>.
This method will be called with just one parameter at a time,
which will correspond one single input item.

Unless told differently (see the C<process_into> option below),
C<DataFlow::Node> will treat as an individual item anything that is:
a scalar, a blessed object, and a reference (of any kind).
And, it will iterate over anything that is either
an array or hash (treated like an array, as described above).

However, it might be convenient in many cases to have things work in a smarter
way. If the input is an array reference, one might expect that every element
in the referenced array should be processed. Or, that every value in a hash
reference should be processed. For cases like that, C<DataFlow::Node>
provides a simple de-referencing mechanism.

=head2 INPUT

The input is provided through the method C<< input() >>, which will gladly
accept anything passed as parameter. However, it must be noticed that it
will not be able to make a distinction between arrays and hashes. Both forms
below will render the exact same results:

    $node->input( qw/all the simple things/ );
    $node->input( all => the, simple => 'things' );

If you do want to handle arrays and hashes differently, we strongly suggest
that you use references:

    $node->input( [ qw/all the simple things/ ] );
    $node->input( { all => the, simple => 'things' } );

And, in the C<process_item>

    my $node = DataFlow:Node->new(
        process_item => sub {
            my ($self,$item) = @_;
            if( ref($item) eq 'ARRAY' ) {
                my @a = @{ $item };
                # ... do something with array @a
            }
            elsif( ref($item) eq 'HASH' ) {
                my %hash = %{ $item };
                # ... handle hash differently
            }
            ...
        }
    );

=head2 PROCESS

The processing of the data is performed by the sub referenced by the
C<< process_item >> attribute. This attribute is B<required> by
C<< DataFlow::Node >>.

=head3 Calling Convention

The code referenced by C<process_item> will be called with two arguments: a
reference to the C<< DataFlow::Node >> object, and one single item from
the input queue, be it a simple scalar, or any type of reference. The code
below shows a typical implementation:

    my $node = DataFlow::Node->new(
        process_item => sub {
            my ($self,$item) = @_;
            # do something with $item
            return $processed_item;
        }
    );

=head3 Inheritance

When inheriting from C<< DataFlow::Node >>, some classes may provide a
default code for C<process_item>. For instance:

    package UCNode;

    use Moose;
    extends 'DataFlow::Node';

    has '+process_item' => (
        default => sub {
            return sub {
                shift; return uc(shift);
            }
        },
    );

Notice that the enclosing C<sub> B<< is mandatory >> in this case. The reason
is that the outter C<sub> is responsible for providing a default value to
C<process_item> and is run only once by C<Moose>, while the inner C<sub>
is the actual value of the code reference C<process_item>, and will be invoked
every time a data item needs to be processed.

=head3 Dereferencing

If you set the attribute C<process_into> as C<true>, then the node will
treat references differently.
It will process the referenced objects, rather than the actual reference.
It will work as follows:

    $scalar = 'some text';
    $ucd->input( \$scalar );
    $res = $ucd->output;
    print ${ $res };     # 'SOME TEXT'

    $aref = [ qw/this is a test/ ];
    $ucd->input( $aref );
    $res = $ucd->output;
    print Dumper($res);  # $VAR1 = [ 'THIS', 'IS', 'A', 'TEST' ]

    $href = { apple => 'red', orange => 'orange', pineapple => 'yellow' };
    $ucd->input( $href );
    $res = $ucd->output;
    print Dumper($res);  # $VAR1 = {
                               apple     => 'RED',
                               orange    => 'ORANGE',
                               pineapple => 'YELLOW',
                           }

    $cref = sub { return 'a dozen dirty pirates' };
    $ucd->input( $cref );
    $res = $ucd->output;
    print $res;          # 'A DOZEN DIRTY PIRATES'

Notice that, except for the code reference, for all others C<Node> will
preserve the original structure.

=head2 OUTPUT

The output is provided by the method C<output>. If called in scalar context
it will return one processed item from the node. If called in list context it
will return all the elements in the queue.

=head1 ATTRIBUTES

=head2 deref

A boolean attribute that signals whether the output of the node will be
de-referenced or if C<Node> will preserve the original reference.

=head2 process_into

A boolean attribute that signals whether references should be dereferenced or
not. If process_into is true, then C<process_item> will be applied into the
values referenced by any scalar, array or hash reference and onto the result
of running any code reference.

=head2 process_item

A code reference that is the actual work horse for this class. It is a
mandatory attribute, and must follow the calling conventions described above.

=head1 METHODS

=head2 input

Provide input data for the node.

=head2 has_input

Returns true if there is data in the input queue, false otherwise.

=head2 process_input

Processes the items in the input queue and place the results in the output
queue.

=head2 output

Fetch data from the node.

=head2 flush

Flushes this node's queues

=head2 has_output

Returns true if there is data in the output queue, false otherwise.

=head2 has_queued_data

Returns true if there is data in either the input or the output queue of this
node, false otherwise.

=head2 process

Convenience method to provide input and immediately get the output.

=head2 get_error

Fetch error messages (if any) from the node.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

L<Scalar::Util>

L<Queue::Base>

=cut
