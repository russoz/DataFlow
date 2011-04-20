package DataFlow::ProcHandler::Scalar;

use strict;
use warnings;

# ABSTRACT: A ProcHandler that processes only scalar values, no refs

# VERSION

use Moose;
with 'DataFlow::Role::ProcHandler';

use namespace::autoclean;

sub _handle {
	return _handle_svalue(@_);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

