package DataFlow::Proc::SimpleFileInput;

use strict;
use warnings;

# ABSTRACT: A node that reads that from a file
# ENCODING: utf8

# VERSION

use Moose;
extends 'DataFlow::Proc';
with 'DataFlow::Role::File';

use autodie;
use Queue::Base;

has '_slurpy_read' => (
	'is' => 'ro',
	'isa' => 'CodeRef',
	'lazy' => 1,
	'default' => sub {
		my $self = shift;
		return sub {
			my $filename = shift;
			open( my $fh, '<', $filename );
			my @slurp = <$fh>;
			close $fh;
            chomp @slurp unless $self->nochomp;

			return [@slurp];
		};
	},
);

has '_fileq' => (
	'is' => 'ro',
	'isa' => 'Queue::Base',
	'lazy' => 1,
	'default' => sub {
		return Queue::Base->new;
	},
);

has '+allows_undef_input' => ( 'default' => 1 );

has '+p' => (
	'default' => sub {
		my $self = shift;

		return sub {
			my $filename = shift;

			return $self->_slurpy_read->( $filename ) if $self->do_slurp;

			# if filename is provided, add it to the queue
			$self->_fileq->add($filename) if defined $filename;	

			# if there is no open file
			if( !$self->has_file ) {
				return if $self->_fileq->empty;
				open( my $fh, '<', $self->_fileq->remove ); ## no critic
				$self->file([$fh, '<']);
			}

			# read a line
			my $file = $self->file;
			my $line = <$file>;
			chomp $line unless $self->nochomp;
			$self->_check_eof;
			return $line;
		};
	},
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

