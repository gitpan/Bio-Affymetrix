#!/usr/bin/perl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CHP.t'

# These tests are a bit lightweight at the moment

#########################

use strict;
use warnings;
use Test::More tests=>25;
# change 'tests => 1' to 'tests => last_test_to_print';

use constant TESTDATA=>"testdata/";

BEGIN { use_ok('Bio::Affymetrix::CDF') };

my $cdf=new Bio::Affymetrix::CDF;

isa_ok($cdf,"Bio::Affymetrix::CDF");

$cdf->parse_from_file(TESTDATA."MAS5-ATH1.CDF");

# Test some facts about this file

is($cdf->original_version(),"GC3.0","original_version works");

is($cdf->original_format(),"MAS5","original_format works");
is($cdf->name(),"ATH1-121501","name works");
is($cdf->rows(),712,"rows works");
is($cdf->cols(),712,"cols works");

is($cdf->original_number_of_probes(),22810,"original_number_of_probes works");
is($cdf->original_max_unit(),23746,"original_max_unit works");
is($cdf->original_num_qc_units(),10,"original_number_qc_units works");

is(scalar(@{$cdf->probesets()}),22810,"correct number of probesets");

# Some random tests on Bio::Affymetrix::CDF::Probeset

is($cdf->probesets()->[5]->name(),"AFFX-BioDn-5_at", "Random name is correct");
is($cdf->probesets()->[5]->unit_name(),"NONE", "another name is correct");
ok(!$cdf->probesets()->[5]->is_sense(), "is_sense works");
is($cdf->probesets()->[5]->original_num_probepairs(),20, "original_number_probepairs works");
is($cdf->probesets()->[5]->original_num_probes(),40, "original_num_pairs works");
is($cdf->probesets()->[5]->unit_type(),"expression", "unit_type works");
is($cdf->probesets()->[5]->CDF(),$cdf, "CDF works");



is($cdf->probesets()->[19857]->name(),"247552_at", "Another random name is correct");
is($cdf->probesets()->[19857]->unit_name(),"NONE", "another name is correct");
ok(!$cdf->probesets()->[19857]->is_sense(), "is_sense works");
is($cdf->probesets()->[19857]->original_num_probepairs(),11, "original_number_probepairs works");
is($cdf->probesets()->[19857]->original_num_probes(),22, "original_num_pairs works");
is($cdf->probesets()->[19857]->unit_type(),"expression", "unit_type works");
is($cdf->probesets()->[19857]->CDF(),$cdf, "CDF works");

