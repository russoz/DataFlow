
package OpenData::Get::Mechanize;

use Moose::Role;
with 'OpenData::Get::Base' => { -excludes => 'content' };
with 'OpenData::Debug';

use WWW::Mechanize;

has obj => (
    is      => 'rw',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        WWW::Mechanize->new(
            agent_alias => $self->agent,
            onerror     => sub { $self->debug(@_) },
            timeout     => $self->timeout
        );
    }
);

sub content {
    my ( $self, $response ) = @_;
    return $response->content;
}

1;

