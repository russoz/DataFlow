#!/usr/bin/perl

use strict;
use warnings;

use DataFlow;

my $flow = DataFlow->new(
    'procs' => [
        sub {
            return uc(shift);
        },
        sub {
            return scalar reverse(shift);
        },
    ],
);

$flow->input('batatas');
print $flow->output . "\n";

