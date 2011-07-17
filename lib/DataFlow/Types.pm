package DataFlow::Types;

use strict;
use warnings;

# ABSTRACT: Type definitions for DataFlow

# VERSION

use MooseX::Types -declare => [
    qw(Processor ProcessorList ProcessorSub ProcPolicy),
    qw(ConversionSubs ConversionDirection),
    qw(Encoder Decoder),
    qw(HTMLFilterTypes),
];

use namespace::autoclean;

use MooseX::Types::Moose qw/Str CodeRef ArrayRef HashRef/;
class_type 'DataFlow';
class_type 'DataFlow::Proc';
role_type 'DataFlow::Role::Processor';
role_type 'DataFlow::Role::ProcPolicy';

use Moose::Util::TypeConstraints 1.01;
use Scalar::Util qw/blessed/;
use Encode;

sub _is_loaded {
    my $class = shift;
    eval { $class->meta };
    return 0 if $@;
    return 1;
}

sub _load_class {
    my $name = shift;
    return q{DataFlow::Proc} if $name eq 'Proc';

    if ( $name =~ m/::/ ) {
        return $name if _is_loaded($name);
        eval "use $name";    ## no critic
        return $name unless $@;
    }

    my $class = "DataFlow::Proc::$name";
    return $class if _is_loaded($class);
    eval "use $class";       ## no critic
    return $class unless $@;

    return $name if _is_loaded($name);
    eval "use $name";        ## no critic
    return $name unless $@;
    die qq{Cannot load class from '$name'};
}

sub _str_to_proc {
    my ( $procname, @args ) = @_;
    my $class = _load_class($procname);
    my $obj = eval { $class->new(@args) };
    die "$@" if "$@";
    return $obj;
}

sub _is_processor {
    my $obj = shift;
    return
         blessed($obj)
      && $obj->can('does')
      && $obj->does('DataFlow::Role::Processor');
}

# where any can be of types:
# - Str
# - [ Str, <options> ]
# - CodeRef
# - DataFlow::Role::Processor
sub _any_to_proc {
    my $elem = shift;
    my $ref  = ref($elem);
    if ( $ref eq '' ) {                # Str?
        return _str_to_proc($elem);
    }
    elsif ( $ref eq 'ARRAY' ) {        # [ Str, <options> ]
        return _str_to_proc( @{$elem} );
    }
    elsif ( $ref eq 'CODE' ) {
        require DataFlow::Proc;
        return DataFlow::Proc->new( p => $elem );
    }
    return $elem;
}

# subtypes CORE

subtype 'Processor' => as 'DataFlow::Role::Processor';
coerce 'Processor' => from 'Any' => via { _any_to_proc($_) };

subtype 'ProcessorList' => as 'ArrayRef[DataFlow::Role::Processor]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorList' => from 'ArrayRef' => via {
    my @list = @{$_};
    my @res = map { _any_to_proc($_) } @list;
    return [@res];
},
  from
  'Str' => via { [ _str_to_proc($_) ] },
  from
  'CodeRef'                        => via { [ _any_to_proc($_) ] },
  from 'DataFlow::Role::Processor' => via { [$_] };

subtype 'ProcessorSub' => as 'CodeRef';
coerce 'ProcessorSub' => from 'DataFlow::Role::Processor' => via {
    my $f = $_;
    return sub { $f->process($_) };
};

subtype 'ProcPolicy' => as 'DataFlow::Role::ProcPolicy';
coerce 'ProcPolicy'  => from 'Str' => via { _make_policy($_) };
coerce 'ProcPolicy'  => from 'ArrayRef' => via { _make_policy( @{$_} ) };

sub _make_policy {
    my ( $policy, @args ) = @_;
    my $class = 'DataFlow::Policy::' . $policy;
    my $obj;
    eval 'use ' . $class . '; $obj = ' . $class . '->new(@args)';   ## no critic
    die $@ if $@;
    return $obj;
}

# subtypes for DataFlow::Proc::Converter ######################

enum 'ConversionDirection' => [ 'CONVERT_TO', 'CONVERT_FROM' ];

subtype 'ConversionSubs' => as 'HashRef[CodeRef]' => where {
    scalar( keys %{$_} ) == 2
      && exists $_->{CONVERT_TO}
      && exists $_->{CONVERT_FROM};
} => message { q(Invalid hash of type 'ConversionSubs') };

# subtypes for DataFlow::Proc::Encoding ######################

subtype 'Decoder' => as 'CodeRef';
coerce 'Decoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return decode( $encoding, shift ) };
};

subtype 'Encoder' => as 'CodeRef';
coerce 'Encoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return encode( $encoding, shift ) };
};

1;

=pod

=head1 SYNOPSIS

When defining a Moose attribute. Example:

       has 'direction' => (
           is  => 'ro',
           isa => 'ConversionDirection',
       );

=head1 DESCRIPTION

This module contains only type definitions. Most of the time there will be
no need to work or mess with this code, unless there is a bug in DataFlow
and/or you are developing a new feature which requires a new type or an
adjustment to an existing one.

=head1 SUBTYPES

=head2 Processor

A L<DataFlow::Proc> object, with coercions.

=head3 Coercions

=head4 from Str

Named processors. If it contains the substring '::', DataFlow will try to
create an object of that type. If it does not, then DataFlow will attempt to
create an object of the type C<< DataFlow::Proc::<STRING> >>. The string 'Proc'
is reserved for creating an object of the type <DataFlow::Proc>.

=head4 from ArrayRef

Named processor with parameters. The first element of the array must be a
text string, subject to the rules used in the previous item. The rest of the
array is passed as-is for the constructor of the object.

=head4 from CodeRef

Code reference, a.k.a. a C<sub>. A processor object will be created:

    DataFlow::Proc->new( p => CODE )

=head4 from DataFlow::Role::Processor

An object that can B<process> something. Objects from both L<DataFlow> and
L<DataFlow::Proc> classes will consume that role, so will all its descendants.
If the element is blessed and C<< ->does('DataFlow::Role::Processor') >>, a
processor object will be created wrapping it:

    DataFlow::Proc->new( p => sub { PROCESSOR->process($_) } )

=head2 ProcessorList

An ArrayRef of L<DataFlow::Proc> objects, with at least one element.

=head3 Coercions

=head4 from ArrayRef

Attempts to make DataFlow::Proc objects out of different things provided in
an ArrayRef. It currently works for:

=begin :list

* Str
* ArrayRef
* CodeRef
* DataFlow::Role::Processor

=end :list

using the same rules as in the subtype C<Processor> described above.
Anything else will trigger an error.

=head4 from Str

An ArrayRef will be created wrapping a named processor, as described in the
coercion section of the C<Processor> subtype above.

=head4 from CodeRef

An ArrayRef will be created wrapping a processor, as described in the
coercion section of the C<Processor> subtype above.

=head4 from DataFlow::Role::Processor

An ArrayRef will be created wrapping the processor, as described in the
coercion section of the C<Processor> subtype above.

=head2 ProcessorSub

A CodeRef, with coercions.

=head3 Coercions

=head4 from DataFlow::Role::Processor

An ArrayRef will be created wrapping the processor.
The rules used above for DataFlow::Role::Processor elements in the ArrayRef
apply.

=head2 ConversionDirection

An enumeration used by type L<DataFlow::Proc::Converter>,
containing two elements:

=for :list
* CONVERT_TO
Indicates the conversion will occur towards a specified type
* CONVERT_FROM
Conversely, indicates the conversion will occur from a specfied type

See DataFlow::Proc::Converter for more information.

=head2 ConversionSubs

A HashRef[CodeRef] also used by DataFlow::Proc::Converter. It must have two
keys only, 'CONVERT_TO' and 'CONVERT_FROM', holding a code reference (sub) for
each of those.

See DataFlow::Proc::Converter for more information.

=head2 Decoder

A CodeRef used by L<DataFlow::Proc::Encoding>. It will be used to decode
strings from some particular character encoding to Perl's internal
representation.

=head3 Coercions

=head4 from Str

It will automagically create a C<sub> that uses function C<< decode() >> from
module L<Encode> to decode from a named encoding.

=head2 Encoder

A CodeRef used by L<DataFlow::Proc::Encoding>. It will be used to encode
strings from Perl's internal representation to some particular character
encoding.

=head3 Coercions

=head4 from Str

It will automagically create a C<sub> that uses function C<< encode() >> from
module L<Encode> to encode to a named encoding.

=cut

