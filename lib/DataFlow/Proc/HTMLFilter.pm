package DataFlow::Proc::HTMLFilter;

use strict;
use warnings;

# ABSTRACT: A HTML filtering processor

# VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use DataFlow::Types qw(HTMLFilterTypes);
use HTML::TreeBuilder::XPath;
use MooseX::Aliases;

has 'search_xpath' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
    'alias'    => 'xpath',
);

has 'result_type' => (
    'is'      => 'ro',
    'isa'     => 'HTMLFilterTypes',
    'default' => 'HTML',
    'alias'   => 'type',
);

has 'ref_result' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'nochomp' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $proc = sub {
            my $html = HTML::TreeBuilder::XPath->new_from_content($_);

            #warn 'xpath is built';
            #warn 'values if VALUES';
            return $html->findvalues( $self->search_xpath )
              if $self->result_type eq 'VALUE';

            #warn 'not values, find nodes';
            my @result = $html->findnodes( $self->search_xpath );

            #use Data::Dumper; warn 'result = '.Dumper(\@result);
            return () unless @result;
            return @result if $self->result_type eq 'NODE';

            #warn 'wants HTML';
            return map { $_->as_HTML } @result;
        };

        my $proc2 = $self->nochomp ? $proc : sub { return chomp $proc->(@_) };
        my $proc3 =
          $self->ref_result ? sub { return [ $proc2->(@_) ] } : $proc2;

        return $self->ref_result ? sub { return [ $proc->(@_) ] } : $proc;
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc::HTMLFilter;

    my $filter_html = DataFlow::Proc::HTMLFilter->new(
        search_xpath => '//td',
    	result_type  => 'HTML',
	);

    my $filter_value = DataFlow::Proc::HTMLFilter->new(
        search_xpath => '//td',
    	result_type  => 'VALUE',
	);

    my $input = <<EOM;
    <html><body>
      <table>
        <tr><td>Line 1</td><td>L1, Column 2</td>
        <tr><td>Line 2</td><td>L2, Column 2</td>
      </table>
    </html></body>
    EOM

    $filter_html->process( $input );
    # @result == '<td>Line 1</td>', ... '<td>L2, Column 2</td>'

    $filter_value->process( $input );
    # @result == q{Line 1}, ... q{L2, Column 2}

=head1 DESCRIPTION

This processor type provides a filter for HTML content.
Each item will be considered as a HTML content and will be filtered
using L<HTML::TreeBuilder::XPath>.

=attr search_xpath

This attribute is a XPath string used to filter down the HTML content.
The C<search_xpath> attribute is mandatory.

=attr result_type

This attribute is a string, but its value B<must> be one of:
C<HTML>, C<VALUE>, C<NODE>. The default is C<HTML>.

=over

=item HTML

The result will be the HTML content specified by C<search_xpath>.

=item VALUE

The result will be the literal value enclosed by the tag and/or attribute
specified by C<search_xpath>.

=item NODE

The result will be a list of L<HTML::Element> objects, as returned by the
C<findnodes> method of L<HTML::TreeBuilder::XPath> class.

=back

Most people will probably use C<HTML> or C<VALUE>, but this option is also
provided in case someone wants to manipulate the HTML elements directly.

=attr ref_result

This attribute is a boolean, and it signals whether the result list should be
added as a list of items to the output queue, or as a reference to an array
of items. The default is 0 (false).

There is a semantic subtlety here: if C<ref_result> is 1 (true),
then one HTML item (input) may generate one or zero ArrayRef item (output),
i.e. it is a one-to-one mapping.
On the other hand, by keeping C<ref_result> as 0 (false), one HTML item
may produce any number of items as result,
i.e. it is a one-to-many mapping.

=cut

