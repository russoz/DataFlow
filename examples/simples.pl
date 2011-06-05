#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use DataFlow;

my $flow = DataFlow->new(
    'procs' => [
        sub { uc },
        sub { scalar reverse },
    ],
);

$flow->input('batatas');
say $flow->output;

