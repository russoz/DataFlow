package DataFlow::Role::Converter;

use strict;
use warnings;

# ABSTRACT: A role for format-conversion processors

# VERSION

use MooseX::Role::Parameterized;
use Moose::Util::TypeConstraints 1.01;

parameter 'type_attr' => (
    'isa'      => 'Str',
    'required' => 1,
);

parameter 'type_class' => (
    'isa'      => 'Str',
    'required' => 1,
);

parameter 'type_class_imports' => (
    'isa'       => 'ArrayRef',
    'predicate' => 'has_imports',
);

parameter 'type_short' => (
    'isa'      => 'Str',
    'required' => 1,
);

role {
    my $p = shift;

    my $attr     = $p->type_attr;
    my $class    = $p->type_class;
    my $opts     = $attr . '_opts';
    my $has_opts = 'has_' . $opts;
    my $short    = $p->type_short;

    my $direction_from = 'FROM_' . uc($short);
    my $direction_to   = 'TO_' . uc($short);

    has 'direction' => (
        is       => 'ro',
        isa      => enum( [ $direction_from, $direction_to ] ),
        required => 1,
    );

    has $opts => (
        is        => 'ro',
        isa       => 'Ref',
        predicate => $has_opts,
    );

    has $attr => (
        is      => 'ro',
        isa     => $class,
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->_attr_default;
        },
    );

    method '_attr_default' => sub {
        my $self = shift;
        my $options = $self->$opts || +{};

        my $use_clause = "use $class";
        $use_clause .= " (@{ $p->type_class_imports })" if $p->has_imports;

        eval $use_clause;    ## no critic
        my $o = $class->new($options);
        eval "no $class";    ## no critic

        return $o;
    };
};

1;

