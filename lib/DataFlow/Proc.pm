package DataFlow::Proc;

use strict;
use warnings;

# ABSTRACT: A data processor class

# VERSION

use Moose;
with 'DataFlow::Role::Processor';
with 'DataFlow::Role::Dumper';

use Moose::Autobox;
use DataFlow::Types qw(ProcessorSub ProcPolicy);

use namespace::autoclean;
use Scalar::Util qw/reftype/;
use Moose::Util::TypeConstraints 1.01;

with 'MooseX::OneArgNew' => { 'type' => 'CodeRef', 'init_arg' => 'p', };

################################################################################

has 'allows_undef_input' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'deref' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'policy' => (
    'is'       => 'ro',
    'isa'      => 'ProcPolicy',
    'coerce'   => 1,
    'lazy'     => 1,
    'builder'  => '_policy',
    'init_arg' => 'policy',
);

has 'p' => (
    'is'       => 'ro',
    'isa'      => 'ProcessorSub',
    'required' => 1,
    'coerce'   => 1,
    'lazy'     => 1,
    'builder'  => '_build_p',
    'documentation' =>
      'Code reference that returns the result of processing one single item',
);

sub _build_p {
    return;
}

sub _policy {
    return 'ProcessInto';
}

sub _process_one {
    my ( $self, $item ) = @_;
    return $self->policy->apply( $self->p, $item );
}

sub _deref {
    my $value = shift;
    my $ref = reftype($value) || '';
    return ${$value}  if $ref eq 'SCALAR';
    return @{$value}  if $ref eq 'ARRAY';
    return %{$value}  if $ref eq 'HASH';
    return $value->() if $ref eq 'CODE';
    return $value;
}

sub process {
    my ( $self, $item ) = @_;

    $self->prefix_dumper( $self->has_name ? $self->name . ' <<' : '<<', $item )
      if $self->dump_input;
    return () unless ( $self->allows_undef_input || defined($item) );

    my @result =
      $self->deref
      ? @{ [ $self->_process_one($item) ]->map( sub { _deref($_) } ) }
      : $self->_process_one($item);

    $self->prefix_dumper( $self->has_name ? $self->name . ' >>' : '>>',
        @result )
      if $self->dump_output;
    return @result;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

	use DataFlow::Proc;

	my $uc = DataFlow::Proc->new( p => sub { uc } );

	my @res = $uc->process( 'something' );
	# @res == qw/SOMETHING/;

	my @res = $uc->process( [qw/aaa bbb ccc/] );
	# @res == [qw/AAA BBB CCC/];

Or

	my $uc_deref = DataFlow::Proc->new(
		deref => 1,
		p     => sub { uc }
	);

	my @res = $uc_deref->process( [qw/aaa bbb ccc/] );
	# @res == qw/AAA BBB CCC/;

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a processing step in
a data-flow.  It attemps to be as generic and unassuming as possible, in order
to provide flexibility for implementors to make their own specialized
processors as they see fit.

Apart from atribute accessors, an object of the type C<DataFlow::Proc> will
provide only a single method, C<process()>, which will process a single
scalar.

=attr name

[Str] A descriptive name for the dataflow. (OPTIONAL)

=attr allows_undef_input

[Bool] It controls whether C<< $self->p->() >> will accept C<undef> as input
or if DataFlow::Proc will filter those out. (DEFAULT = false)

=attr deref

[Bool] Signals whether the result of the processing will be de-referenced
upon output or if DataFlow::Proc will preserve the original reference.
(DEFAULT = false)

=attr dump_input

[Bool] Dumps the input parameter to STDERR before processing. See
L<DataFlow::Role::Dumper>. (DEFAULT = false)

=attr dump_output

[Bool] Dumps the results to STDERR after processing. See
L<DataFlow::Role::Dumper>. (DEFAULT = false)

=attr p

[CodeRef] The actual work horse for this class. It is treated as a function,
not as a method, as in:

	my $proc = DataFlow::Proc->new( p => sub { ucfirst } );

The sub referenced by C<p> is run with a localized version the special
variable C<< $_ >>, containing the value of the data to be processed.

It only makes sense to access C<$self> when one is sub-classing DataFlow::Proc
and adding new attibutes or methods, in which case one can do as below:

	package MyProc;

	use Moose;
	extends 'DataFlow::Proc';

	has 'x_factor' => ( isa => 'Int' );

	sub _build_p {
		my $self = shift;
		return sub { $_ * int( rand( $self->x_factor ) ) };
	}

	package main;

	my $proc = MyProc->new( x_factor => 5 );

This sub will be called in array context. There is no other restriction on
what this code reference can or should do. (REQUIRED)

=method process

Processes one single scalar (or anything else that can be passed in on scalar,
such as references or globs), and returns the application of the function
C<< $self->p->() >> over the item.

=cut

