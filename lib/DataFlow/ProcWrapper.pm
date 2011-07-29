package DataFlow::ProcWrapper;

use strict;
use warnings;

# ABSTRACT: Wrapper around a processor

# VERSION

use Moose;
with 'DataFlow::Role::Processor';

use Moose::Autobox;
use namespace::autoclean;

use DataFlow::Item;
use DataFlow::Types qw(Processor);

has 'input_chan' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => 'default',
);

has 'output_chan' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->input_chan },
);

has 'on_proc' => (
    is       => 'ro',
    isa      => 'Processor',
    required => 1,
    init_arg => 'wraps',
    coerce   => 1,
);

sub _itemize_response {
    my ( $self, $input_item, @response ) = @_;
    return ($input_item) unless @response;
    return @{
        @response->map(
            sub { $input_item->clone->set_data( $self->output_chan, $_ ) }
        )
      };
}

sub process {
    my ( $self, $item ) = @_;

    return unless defined $item;
    if ( ref($item) eq 'DataFlow::Item' ) {
        my $data = $item->get_data( $self->input_chan );
        return ($item) unless $data;
        return $self->_itemize_response( $item,
            $self->on_proc->process($data) );
    }
    else {
        my $data       = $item;
        my $empty_item = DataFlow::Item->new();
        return ($empty_item) unless $data;
        return $self->_itemize_response( $empty_item,
            $self->on_proc->process($data) );
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::ProcWrapper;
    use DataFlow::Item;

	my $wrapper = DataFlow::ProcWrapper->new( wraps => sub { lc } );
	my $item = DataFlow::Item->itemize( 'default', 'WAKAWAKAWAKA' );
	my @result = $wrapper->process($item);
	# $result[0]->get_data('default') equals to 'wakawakawaka'

=head1 DESCRIPTION

This class C<DataFlow::ProcWrapper> consumes the L<DataFlow::Role::Processor>
role, but this is not a "common" processor and it should not be used as such.
Actually, it is supposed to be used internally by DataFlow alone, so in theory,
if not in practice, we should be able to ignore its existence.

C<ProcWrapper> will, as the name suggests, wraps around a processor (read
a Proc, a DataFlow, a naked sub or a named processor), and provides a layer
of control on the input and output channels.

=attr input_chan

Name of the input channel. The L<DataFlow::Item> may carry data in distinct
"channels", and here we can select which channel we will take the data from.
If not specified, it will default to the literal string C<< 'default' >>.

=attr output_chan

Similarly, the output channel's name. If not specified, it will default to
the same channel used for input.

=method process

This works like the regular C<process()> method in a processor, except that
it expects to receive an object of the type L<DataFlow::Item>.

Additionaly, one can pass a random scalar as argument, and add a
second argument that evaluates to a true value, and the scalar argument will
be automagically "boxed" into a C<DataFlow::Item> object.

Once the data is within a C<DataFlow::Item>, data will be pulled from the
specified channel, will call the wrapped processor's C<process()> method.

It will always return an array with one or more elements, all of them of the
C<DataFlow::Item> type.

=cut

