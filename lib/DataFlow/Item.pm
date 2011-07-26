package DataFlow::Item;

use strict;
use warnings;

# ABSTRACT: A piece of information to be processed

# VERSION

use Moose;
use Moose::Autobox;
use MooseX::ChainedAccessors;

use namespace::autoclean;

has 'metadata' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[Any]',
    'handles' => { metakeys => sub { shift->metadata->keys }, },
	'lazy' => 1,
	'default' => sub { {} },
);

has 'channels' => (
    'is'      => 'rw',
    'isa'     => 'HashRef[Any]',
    'handles' => { channel_list => sub { shift->channels->keys }, },
	'lazy' => 1,
	'default' => sub { {} },
	'traits' => [ 'Chained' ],
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

sub narrow {
    my ( $self, $channel ) = @_;
    return __PACKAGE__->new( metadata => $self->metadata, )
      ->set_data( $channel, $self->channels->{$channel} );
}

sub clone {
    my $self = shift;
    return __PACKAGE__->new( metadata => $self->metadata )
      ->channels( $self->channels );
}

sub itemize {
    my ( $class, $channel, $data ) = @_;
    return __PACKAGE__->new()->set_data( $channel, $data );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Item;

=head1 DESCRIPTION

Holds data and metadata for processing through DataFlow

=method itemize

Creates a new C<DataFlow::Item> with a certain data into a specific channel.

=method channel

Returns the data from one specific channel.

=cut

