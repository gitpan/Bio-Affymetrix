#!/usr/bin/perl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CDF.t'

# These tests are a bit lightweight at the moment

#########################

use strict;
use warnings;
use Test::More tests=>37;
# change 'tests => 1' to 'tests => last_test_to_print';

use constant TESTDATA=>"testdata/";

BEGIN { use_ok('Bio::Affymetrix::CDF');use_ok('Bio::Affymetrix::CHP'); };

my $cdf=new Bio::Affymetrix::CDF({"probemode"=>0});

isa_ok($cdf,"Bio::Affymetrix::CDF");

$cdf->parse_from_file(TESTDATA."MAS5-ATH1.CDF");

# MAS 5 test
{
    my $chp=new Bio::Affymetrix::CHP($cdf);
    
    isa_ok($cdf,"Bio::Affymetrix::CDF");
    
    is($cdf,$chp->CDF(),"CDF function works");

    $chp->parse_from_file(TESTDATA."MAS5-no-comparison-ATH1.CHP");

    is($chp->original_format(),"MAS5","original format succesfully detected");
    is($chp->original_version(),12,"original version succesfully detected");
    is($chp->cols(),712,"cols works");
    is($chp->rows(),712,"rows works");
    is($chp->original_number_of_probes(),22810,"original_number_of_probes works");
    is($chp->original_number_qc_units(),10,"original_number_qc_units works");
    is($chp->original_com_progid(),"GeneChipAnalysis.GEBaseCall.1","original_com_progid works");
    is($chp->CEL_file_name(),"e:\\affymetrix\\testdata\\customers_2004\\bekir uelker\\Uelker_1-8_WT_Col-0-S_ATH1.CEL","CEL_file_name works");
    is($chp->probe_array_type(),"ATH1-121501","probe_array_type works");
    is($chp->algorithm_name(),"ExpressionStat","algorithm_name works");
    is($chp->algorithm_version(),"5.0","algorithm_version works");

    is(ref $chp->summary_statistics,"HASH","summary statistics works");
    is($chp->summary_statistics->{"RawQ"},3.34,"summary statistics gives right number for RawQ");

    is(ref $chp->summary_statistics,"HASH","summary statistics works");

    # Check results against master list
    my $fail=0;

    open TESTFILE,"<".TESTDATA."MAS5-no-comparison-as-text.txt" or die "Cannot open comparison file";
    while (<TESTFILE>) {
	my ($name,$signal)=split;
	if ($chp->probe_set_results()->{$name}->{"Signal"}!=$signal) {
	    $fail=1;
	    last;
	}
    }
    close TESTFILE;
    ok($fail,"Signal values consistant with file");

}


# GCOS v1.2 test
{
    my $chp=new Bio::Affymetrix::CHP($cdf);
    
    isa_ok($cdf,"Bio::Affymetrix::CDF");
    
    is($cdf,$chp->CDF(),"CDF function works");

    $chp->parse_from_file(TESTDATA."GCOS1.2-no-comparison-ATH1.CHP");

    is($chp->original_format(),"XDA","original format succesfully detected");
    is($chp->original_version(),1,"original version succesfully detected");
    is($chp->cols(),712,"cols works");
    is($chp->rows(),712,"rows works");
    is($chp->original_number_of_probes(),22810,"original_number_of_probes works");
    is($chp->original_number_qc_units(),10,"original_number_qc_units works");
    is($chp->original_com_progid(),"GeneChip.CallGEBaseCall.1","original_com_progid works");
    is($chp->CEL_file_name(),"Pourtau_1-1_lowN_Rep1_ATH1.CEL","CEL_file_name works");
    is($chp->probe_array_type(),"ATH1-121501","probe_array_type works");
    is($chp->algorithm_name(),"ExpressionStat","algorithm_name works");
    is($chp->algorithm_version(),"5.0","algorithm_version works");

    is(ref $chp->summary_statistics,"HASH","summary statistics works");
    is($chp->summary_statistics->{"RawQ"},"2.37","summary statistics gives right number for RawQ");

    is(ref $chp->summary_statistics,"HASH","summary statistics works");

    # Check results against master list
    my $fail=0;

    open TESTFILE,"<".TESTDATA."MAS5-no-comparison-as-text.txt" or die "Cannot open comparison file";
    while (<TESTFILE>) {
	my ($name,$signal)=split;
	if ($chp->probe_set_results()->{$name}->{"Signal"}!=$signal) {
	    $fail=1;
	    last;
	}
    }
    close TESTFILE;
    ok($fail,"Signal values consistant with file");

}
