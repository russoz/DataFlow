package DataFlow::Proc;

use strict;
use warnings;

# ABSTRACT: A generic processing node in a data flow
# ENCODING: utf8

# VERSION

use Moose;
with 'DataFlow::Role::Dumper';

use Scalar::Util qw/blessed reftype/;

has 'name' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

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

has 'process_into' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 1,
);

has 'dump_input' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'dump_output' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'p' => (
    'is'            => 'ro',
    'isa'           => 'CodeRef',
    'required'      => 1,
    'documentation' => 'Returns the result of processing one single item',
);

sub process_one {
    my ( $self, $item ) = @_;

    $self->prefix_dumper( '>>', $item ) if $self->dump_input;
    return unless ( $self->allows_undef_input || defined($item) );

    my @result = $self->_handle_list($item);
    $self->prefix_dumper( '<<', @result ) if $self->dump_output;

    return @result if wantarray;

    confess('Multiple values in result for a scalar context') if $#result > 0;
    return $result[0];
}

##############################################################################
# code to handle different types of input
#   ex: array-refs, hash-refs, code-refs, etc...

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return 'SVALUE' unless $r;
    return 'OBJECT' if blessed($p);
    return $r;
}

sub _handle_list {
    my ( $self, @args ) = @_;
    my @result = ();

    #use Data::Dumper; warn '_handle_list(params) = '.Dumper(@_);
    foreach my $item (@args) {
        my $type = _param_type($item);
        confess('There is no handler for this parameter type!')
          unless exists $self->_handlers->{$type};
        push @result, $self->_handlers->{$type}->( $self->p, $item );
    }
    return @result;
}

##############################################################################
#
#  _handlers
#
#  _handlers is a hash reference, with reference types (and some other special
#  strings) as keys, and code references (a.k.a. handlers) as values.
#
#  For each key, a handler will be defined taking into account whether this
#  node has process_into == 1 and/or deref == 1.
#

has '_handlers' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[CodeRef]',
    'lazy'    => 1,
    'default' => sub {
        my $me           = shift;
        my $type_handler = {
            'SVALUE' => \&_handle_svalue,
            'OBJECT' => \&_handle_svalue,
            'SCALAR' => $me->process_into ? \&_handle_scalar_ref
            : \&_handle_svalue,
            'ARRAY' => $me->process_into ? \&_handle_array_ref
            : \&_handle_svalue,
            'HASH' => $me->process_into ? \&_handle_hash_ref : \&_handle_svalue,
            'CODE' => $me->process_into ? \&_handle_code_ref : \&_handle_svalue,
        };
        return $type_handler unless $me->deref;

        return {
            'SVALUE' => sub { $type_handler->{'SVALUE'}->(@_) },
            'OBJECT' => sub { $type_handler->{'OBJECT'}->(@_) },
            'SCALAR' => sub { ${ $type_handler->{'SCALAR'}->(@_) } },
            'ARRAY'  => sub { @{ $type_handler->{'ARRAY'}->(@_) } },
            'HASH'   => sub { %{ $type_handler->{'HASH'}->(@_) } },
            'CODE'   => sub { $type_handler->{'CODE'}->(@_)->() },
        };
    },
);

sub _handle_svalue {
    my ( $p, $item ) = @_;
    return $p->($item);
}

sub _handle_scalar_ref {
    my ( $p, $item ) = @_;
    my $r = $p->($$item);
    return \$r;
}

sub _handle_array_ref {
    my ( $p, $item ) = @_;

    #use Data::Dumper; warn 'handle_array_ref :: item = ' . Dumper($item);
    my @r = map { $p->($_) } @{$item};
    return [@r];
}

sub _handle_hash_ref {
    my ( $p, $item ) = @_;
    my %r = map { $_ => $p->( $item->{$_} ) } keys %{$item};
    return {%r};
}

sub _handle_code_ref {
    my ( $p, $item ) = @_;
    return sub { $p->( $item->() ) };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=head1 SYNOPSIS

    use DataFlow::Proc;

    my $uc = DataFlow::Proc->new(
        process_item => sub {
            shift; return uc(shift);
        }
    );

    my @res = $uc->process_one( 'something' );
    # @res == qw/SOMETHING/;

    my @res = $uc->process_one( [qw/aaa bbb ccc/] );
    # @res == [qw/AAA BBB CCC/];

Or

    my $uc_deref = DataFlow::Proc->new(
        deref        => 1,
        process_item => sub {
            shift; return uc(shift);
        }
    );

    my @res = $uc_deref->process_one( [qw/aaa bbb ccc/] );
    # @res == qw/AAA BBB CCC/;

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a procesing step in a
data-flow.  It attemps to be as generic and unassuming as possible, in order to
provide flexibility for implementors to make their own nodes as they see fit.

An object of the type C<DataFlow::Proc> does three things:
accepts some data as input,
processes that data,
provides the transformed data as output.

=head1 ATTRIBUTES

=head2 deref

A boolean attribute that signals whether the output of the node will be
de-referenced or if C<Node> will preserve the original reference.

=head2 process_into

A boolean attribute that signals whether references should be dereferenced or
not. If process_into is true, then C<process_item> will be applied into the
values referenced by any scalar, array or hash reference and onto the result
of running any code reference.

=head2 p

A code reference that is the actual work horse for this class. It is a
mandatory attribute, and must follow the calling conventions described above.

=head1 METHODS

=head2 process_one

Processes one single scalar (or anything else that can be passed in on scalar,
such as references or globs), and returns the application of the function
C<p()> over the item.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

L<Scalar::Util>

=cut
