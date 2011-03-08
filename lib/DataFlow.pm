package DataFlow;

use strict;
use warnings;

# ABSTRACT: A framework for dataflow processing
# ENCODING: utf8

# VERSION

1;

=pod

=head1 SYNOPSIS

	use DataFlow::Node;
	use DataFlow::Chain;

	my $chain = DataFlow::Chain->new(
		DataFlow::Node->new(
			process_item => sub {
				... do something
			}
		),
		DataFlow::Node->new(
			process_item => sub {
				... do something else
			}
		),
	);

	my $output = $chain->process($input);

=head1 DESCRIPTION

This is a framework for data flow processing. It started as a spinoff project
from L<OpenData-BR|http://www.opendatabr.org/>.

As of now (Mar, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and also
the documentation for L<DataFlow::Node> and L<DataFlow::Chain>, to start with.

An article has been recently written in Brazilian Portuguese about this
framework, per the São Paulo Perl Mongers "Equinócio" (Equinox) virtual event.
Although an English version of the article in in the plans, you can figure
a good deal out of the original one at

L<http://sao-paulo.pm.org/equinocio/2011/mar/5>

Any doubts, feel free to get in touch.

=cut

