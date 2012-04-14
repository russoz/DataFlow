package DataFlow::Item;

use strict;
use warnings;

# ABSTRACT: A wrapper around the regular data processed by DataFlow

# VERSION

use Moose;
use Moose::Autobox;
use MooseX::Attribute::Chained;

use namespace::autoclean;

has 'metadata' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[Any]',
    'handles' => { metakeys => sub { shift->metadata->keys }, },
    'lazy'    => 1,
    'default' => sub { {} },
);

has 'channels' => (
    'is'      => 'rw',
    'isa'     => 'HashRef[Any]',
    'handles' => { channel_list => sub { shift->channels->keys }, },
    'lazy'    => 1,
    'default' => sub { {} },
    'traits'  => ['Chained'],
);

sub get_metadata {
    my ( $self, $key ) = @_;
    return $self->metadata->{$key};
}

sub set_metadata {
    my ( $self, $key, $data ) = @_;
    $self->metadata->{$key} = $data;
    return $self;
}

sub get_data {
    my ( $self, $channel ) = @_;
    return $self->channels->{$channel};
}

sub set_data {
    my ( $self, $channel, $data ) = @_;
    $self->channels->{$channel} = $data;
    return $self;
}

sub itemize {    ## no critic
    return __PACKAGE__->new()->set_data( $_[1], $_[2] );
}

sub clone {
    my $self = shift;
    my @c    = %{ $self->channels };
    return __PACKAGE__->new( metadata => $self->metadata )->channels( {@c} );
}

sub narrow {
    my ( $self, $channel ) = @_;
    return __PACKAGE__->new( metadata => $self->metadata, )
      ->set_data( $channel, $self->get_data($channel) );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Item;
	my $item = DataFlow::Item->itemize( 'channel_name', 42 );
	say $item->get_data( 'channel_name' );

	$item->set_metadata( 'somekey', q{some meta value} );
	say item->get_metadata( 'somekey' );

=head1 DESCRIPTION

Wraps data and metadata for processing through DataFlow.

=attr metadata

A hash reference containing metada for the DataFlow.

=attr channels

A hash reference containing data for each 'channel'.

=method metakeys

A convenience method that returns the list of the keys to the metadata hash
reference.

=method channel_list

A convenience method that returns the list of the keys to the channels hash
reference.

=method get_metadata

Returns a metadata value, identified by its key.

=method set_metadata

Sets a metadata value, identified by its key.

=method get_data

Returns a channel value, identified by the channel name.

=method set_data

Sets a channel value, identified by the channel name.

=method itemize

This is a B<class> method that creates a new C<DataFlow::Item> with a certain
data stored in a specific channel. As a class method, it must be called like
this:

	my $item = DataFlow::Item->itemize( 'channel1', { my => data } );

=method clone

Makes a copy of the C<DataFlow::Item> object. Note that the whole metadata
contents (hash reference, really) is passed by reference to the new instance,
while the contents of the channels are copied one by one into the new object.

=method narrow

Makes a copy of the C<DataFlow::Item> object narrowed to one single channel.
In other words, it is like clone, but the C<channels> will contain B<only>
the channel specified as a parameter.

=cut

