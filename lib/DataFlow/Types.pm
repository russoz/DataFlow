package DataFlow::Types;

use strict;
use warnings;

# ABSTRACT: Type definitions for DataFlow

# VERSION

use MooseX::Types -declare => [
    qw(ProcessorChain Processor ProcPolicy Encoder Decoder HTMLFilterTypes),
    qw(ConversionSubs ConversionDirection)
];

use namespace::autoclean;

use MooseX::Types::Moose qw/Str CodeRef ArrayRef HashRef/;
class_type 'DataFlow';
class_type 'DataFlow::Proc';
role_type 'DataFlow::Role::Processor';

use Moose::Util::TypeConstraints 1.01;
use Scalar::Util qw/blessed/;
use Encode;

#################### DataFlow ######################

sub _load_class {
    my $name = shift;
    return q{DataFlow::Proc} if $name eq 'Proc';

    if ( $name =~ m/::/ ) {
        eval "use $name";    ## no critic
        return $name unless $@;
    }

    my $class = "DataFlow::Proc::$name";
    eval "use $class";      ## no critic
    return $class unless $@;

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

# subtypes
subtype 'ProcessorChain' => as 'ArrayRef[DataFlow::Proc]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorChain' => from 'ArrayRef' => via {
    my @list = @{$_};
    my @res  = map {
        my $elem = $_;
        my $ref  = ref($elem);
        if ( $ref eq '' ) {    # String?
            _str_to_proc($elem);
        }
        elsif ( $ref eq 'ARRAY' ) {
            _str_to_proc( @{$elem} );
        }
        elsif ( $ref eq 'CODE' ) {
            require DataFlow::Proc;
            DataFlow::Proc->new( p => $elem );
        }
        elsif ( _is_processor($elem) ) {
            require DataFlow::Proc;
            DataFlow::Proc->new( p => sub { $elem->process($_) } );
        }
        else {
            die q{Invalid element (}
              . join( q{,}, $ref, $elem )
              . q{) passed instead of a processor};
        }
    } @list;
    return [@res];
},
  from
  'Str'          => via { [ _str_to_proc($_) ] },
  from 'CodeRef' => via {
    require DataFlow::Proc;
    [ DataFlow::Proc->new( p => $_ ) ];
  },
  from 'DataFlow' => via {
    my $proc = $_;
    require DataFlow::Proc;
    [ DataFlow::Proc->new( p => sub { $proc->process($_) } ) ];
  },
  from 'DataFlow::Proc' => via { [$_] };

#################### DataFlow::Proc ######################

subtype 'Processor' => as 'CodeRef';
coerce 'Processor' => from 'DataFlow::Role::Processor' => via {
    my $f = $_;
    return sub { $f->process($_) };
};

use DataFlow::Role::ProcPolicy;
subtype 'ProcPolicy' => as 'DataFlow::Role::ProcPolicy';
coerce 'ProcPolicy' => from 'Str' => via { _make_policy($_) } => from
  'ArrayRef' => via { _make_policy( @{$_} ) };

sub _make_policy {
    my ( $policy, @args ) = @_;
    my $class = 'DataFlow::Policy::' . $policy;
    my $obj;
    eval 'use ' . $class . '; $obj = ' . $class . '->new(@args)';   ## no critic
    die $@ if $@;
    return $obj;
}

#################### DataFlow::Proc::Converter ######################

enum 'ConversionDirection' => [ 'CONVERT_TO', 'CONVERT_FROM' ];

subtype 'ConversionSubs' => as 'HashRef[CodeRef]' => where {
    scalar( keys %{$_} ) == 2
      && exists $_->{CONVERT_TO}
      && exists $_->{CONVERT_FROM};
} => message { q(Invalid 'ConversionSubs' hash) };

#################### DataFlow::Proc::Encoding ######################

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

#################### DataFlow::Proc::HTMLFilter ######################

enum 'HTMLFilterTypes', [qw(NODE HTML VALUE)];

1;

__END__

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

=head2 ProcessorChain

An ArrayRef of L<DataFlow::Proc> objects, with at least one element.

=head3 Coercions

=head4 from ArrayRef

Attempts to make DataFlow::Proc objects out of different things in an ArrayRef.
Currently it works for:

=begin :list

* Str
Named processors. If it contains the substring '::', DataFlow will try to
create an object of that type. If it does not, then DataFlow will attempt to
create an object of the type C<< DataFlow::Proc::<STRING> >>. The string 'Proc'
is reserved for creating an object of the type <DataFlow::Proc>.
* ArrayRef
Named processor with parameters. The first element of the array must be a
text string, subject to the rules used in the previous item. The rest of the
array is passed as parameters for constructing the object.
* CodeRef
Code reference, a.k.a. a C<sub>. A processor object will be created:

    DataFlow::Proc->new( p => CODE )

* DataFlow::Proc
A processor. If the element is blessed and C<< ->isa('DataFlow::Proc') >>, it
will be used as-is in the resulting ArrayRef.
* DataFlow
A dataflow. If the element is blessed and C<< ->isa('DataFlow') >>, a processor
object will be created wrapping it:

    DataFlow::Proc->new( p => sub { DATAFLOW->process($_) } )

=end :list

Anything else will trigger an error.

=head4 from Str

An ArrayRef will be created wrapping a named processor.
The rules used above for Str elements in the ArrayRef apply.

=head4 from CodeRef

An ArrayRef will be created wrapping a processor.
The rules used above for CodeRef elements in the ArrayRef apply.

=head4 from DataFlow::Proc

An ArrayRef will be created wrapping the processor.
The rules used above for DataFlow::Proc elements in the ArrayRef apply.

=head4 from DataFlow

An ArrayRef will be created wrapping a processor.
The rules used above for DataFlow elements in the ArrayRef apply.

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

=head2 HTMLFilterTypes

An enumeration used by type L<DataFlow::Proc::HTMLFilter>,
containing three elements, representing the type of result the HTMLFilter
object will provide:

=for :list
* NODE
Results will be L<HTML::Element> objects
* HTML
Results will be HTML content.
* VALUE
Results will be literal values

See DataFlow::Proc::HTMLFilter for more information.

=cut

