package DataFlow::ProcWrapper;

use strict;
use warnings;

# ABSTRACT: Wrapper around a processor

# VERSION

use Moose;
with 'DataFlow::Role::Processor';

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

has '_on_proc' => (
    is       => 'ro',
    isa      => 'Processor',
    required => 1,
    init_arg => 'wraps',
    coerce   => 1,
);

sub _itemize_response {
    my ( $self, $input_item, @response ) = @_;
    return
      map { $input_item->clone->set_data( $self->output_chan, $_ ) } @response;
}

sub process {
    my ( $self, $item, $is_raw ) = @_;

    my $data = $is_raw ? $item : $item->get_data( $self->input_chan );
    return $self->_itemize_response(
        $is_raw ? DataFlow::Item->new() : $item,
        $self->_on_proc->process($data)
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Channel;

=head1 DESCRIPTION

Holds data and metadata for processing through DataFlow

=method itemize

Creates a new C<DataFlow::Item> with a certain data into a specific channel.

=method channel

Returns the data from one specific channel.

=cut

