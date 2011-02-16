
package DataFlow::Node::URLRetriever;

use Moose;
extends 'DataFlow::Node';

use DataFlow::Node::URLRetriever::Get;

has _get => (
    is      => 'rw',
    isa     => 'DataFlow::Node::URLRetriever::Get',
    lazy    => 1,
    default => sub { DataFlow::Node::URLRetriever::Get->new }
);

has baseurl => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_baseurl',
);

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $item ) = @_;

            #warn 'process_item:: item = '.$item;
            my $url =
              $self->has_baseurl
              ? URI->new_abs( $item, $self->baseurl )->as_string
              : $item;

            #$self->debug("process_item:: url = $url");
            return $self->_get->get($url);
          }
    },
);

__PACKAGE__->meta->make_immutable;

1;

