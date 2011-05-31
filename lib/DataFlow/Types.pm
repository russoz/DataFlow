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
                  DataFlow::Proc->new( p => sub { $proc->process(@_) } );
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

