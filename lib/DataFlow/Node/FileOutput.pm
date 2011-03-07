package DataFlow::Node::FileOutput;

#ABSTRACT: A node that writes data to a file

use strict;
use warnings;

# VERSION

use Moose;
extends 'DataFlow::Node::NOP';
with 'DataFlow::Role::File';

has _get_item => (
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
    lazy     => 1,
    default  => sub {
        my $self = shift;

        #use Data::Dumper; print STDERR Dumper($self);

        return sub {

            #use Data::Dumper; print STDERR 'slurpy ' .Dumper($self);
            my $fh    = $self->_handle;
            my @slurp = <$fh>;
            chomp @slurp unless $self->nochomp;

            #use Data::Dumper; print STDERR 'slurpy ' .Dumper([@slurp]);
            return [@slurp];
          }
          if $self->do_slurp;

        # not a slurp, rather line by line
        if ( $self->nochomp ) {
            return sub {

                #use Data::Dumper; print STDERR 'nochompy ' .Dumper($self);
                my $fh   = $self->_handle;
                my $item = <$fh>;
                return $item;
            };
        }
        else {
            return sub {

                #use Data::Dumper; print STDERR 'chompy ' .Dumper($self);
                my $fh   = $self->_handle;
                my $item = <$fh>;
                chomp $item;
                return $item;
            };
        }
    },
);

override 'process_input' => sub {
    my $self = shift;

    until ( $self->has_handle ) {
        return unless $self->has_input;
        my $nextfile = $self->_dequeue_input;

        eval { $self->_handle($nextfile) };
        $self->confess($@) if $@;

        # check for EOF
        $self->_check_eof;
    }

    my @item = ( $self->_get_item->() );

    #use Data::Dumper; print STDERR 'items '.Dumper( [ @item ] );

    # check for EOF
    $self->_check_eof;

    # TODO some device to add multiple items (<infinity) to the output queue
    $self->_add_output( $self->_handle_list(@item) );
};

__PACKAGE__->meta->make_immutable;

1;

