
package DataFlow::Node::URLRetriever::Get::Mechanize;

use Moose::Role;

use WWW::Mechanize;

sub _make_obj {
    my $self = shift;
    return WWW::Mechanize->new(
        agent   => $self->agent,
        onerror => sub { $self->debug(@_) },
        timeout => $self->timeout
    );
}

sub _content {
    my ( $self, $response ) = @_;
    #print STDERR "mech _content\n";
    return $response->content;
}

1;

