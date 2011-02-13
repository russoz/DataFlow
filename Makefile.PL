#!/usr/bin/env perl

use inc::Module::Install;

name 'DataFlow';
license 'perl';
version_from 'lib/DataFlow/Node.pm';

requires 'Moose';
requires 'namespace::autoclean';
requires 'Scalar::Util';
requires 'List::Util';
requires 'List::MoreUtils';
requires 'Queue::Base';
requires 'HTML::TreeBuilder::XPath';

# URLRetriever
requires 'LWP::Curl';
requires 'WWW::Mechanize';

requires 'MooseX::OneArgNew';
requires 'MooseX::Types::IO';
requires 'version' => 0.86;

test_requires 'Test::More';
test_requires 'Test::Pod' => '1.41';
test_requires 'Test::Pod::Coverage' => '1.08';
test_requires 'Pod::Coverage::TrustPod';
test_requires 'Test::UseAllModules';
test_requires 'aliased';

tests 't/*.t t/*/*t t/*/*/*t t/*/*/*/*t';

auto_install;
WriteAll;

