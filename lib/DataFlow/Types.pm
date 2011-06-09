package DataFlow::Types;

use strict;
use warnings;

# ABSTRACT: Type definitions for DataFlow

# VERSION

use MooseX::Types -declare => [
    qw(ProcessorChain Encoder Decoder HTMLFilterTypes),
    qw(ConversionSubs ConversionDirection)
];

use namespace::autoclean;

use MooseX::Types::Moose qw/Str CodeRef ArrayRef HashRef/;
class_type 'DataFlow';
class_type 'DataFlow::Proc';

use Moose::Util::TypeConstraints 1.01;
use Scalar::Util qw/blessed/;
use Encode;

#################### DataFlow ######################

sub _load_class {
    my $str = shift;
    if ( $str eq 'Proc' ) {
        eval "use $str";    ## no critic
        return $str unless $@;
    }
    elsif ( $str =~ m/::/ ) {
        eval "use $str";    ## no critic
        return $str unless $@;
    }
    my $class = "DataFlow::Proc::$str";
    eval "use $class";      ## no critic
    return $class unless $@;
    eval "use $str";        ## no critic
    return $str unless $@;
    die qq{Cannot load class from '$str'};
}

sub _str_to_proc {
    my ( $str, $params ) = @_;
    my $class = _load_class($str);
    my $obj   = eval {
        ( defined($params) and ( ref($params) eq 'HASH' ) )
          ? $class->new($params)
          : $class->new;
    };
    die "$@" if "$@";
    return $obj;
}

# subtypes
subtype 'ProcessorChain' => as 'ArrayRef[DataFlow::Proc]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorChain' => from 'ArrayRef' => via {
    my @list = @{$_};
    my @res  = ();
    while ( my $proc = shift @list ) {
        my $ref = ref($proc);
        if ( $ref eq '' ) {    # String?
            push @res,
              ref( $list[0] ) eq 'HASH'
              ? _str_to_proc( $proc, shift @list )
              : _str_to_proc($proc);
        }
        elsif ( $ref eq 'CODE' ) {
            use DataFlow::Proc;
            push @res, DataFlow::Proc->new( p => $proc );
        }
        elsif ( blessed($proc) ) {
            if ( $proc->isa('DataFlow::Proc') ) {
                push @res, $proc;
            }
            elsif ( $proc->isa('DataFlow') ) {
                push @res,
                  DataFlow::Proc->new( p => sub { $proc->process($_) } );
            }
            else {
                die q{Invalid object (} . $ref
                  . q{) passed instead of a processor};
            }
        }
        else {
            die q{Invalid element (}
              . join( q{,}, $ref, $proc )
              . q{) passed instead of a processor};
        }
    }
    return [@res];
},
  from
  'Str' => via { [ _str_to_proc($_) ] },
  from
  'CodeRef' => via { [ DataFlow::Proc->new( p => $_ ) ] },
  from
  'DataFlow'            => via { $_->procs },
  from 'DataFlow::Proc' => via { [$_] };

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
is reserved for creating an object of the type <DataFlow::Proc>. If the next
element in the ArrayRef is a HashRef, it will be used as argument for the
object constructor.
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

