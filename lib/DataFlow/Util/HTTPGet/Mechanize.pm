package DataFlow::Util::HTTPGet::Mechanize;

use strict;
use warnings;

# ABSTRACT: A HTTP Getter implementation using WWW::Mechanize

# VERSION

use Moose::Role;

use WWW::Mechanize;

sub _make_obj {
    my $self = shift;
    return WWW::Mechanize->new(
        agent   => $self->agent,
        onerror => sub { confess(@_) },
        timeout => $self->timeout
    );
}

sub _content {
    my ( $self, $response ) = @_;

    #print STDERR "mech _content\n";
    return $response->content;
}

1;

