#!/usr/bin/perl

package Bio::Affymetrix::CHP;

# Docs come before the code

=head1 NAME

Bio::Affymetrix::CHP- parse Affymetrix CHP files

=head1 SYNOPSIS

use Bio::Affymetrix::CHP;

use Bio::Affymetrix::CDF;

# Parse the CDF file

my $cdf=new CDF();

$cdf->parse_from_file("foo.cdf");


# Make a new CHP object, using the CDF file

my $chp=new CHP($cdf);

# Parse CHP file

$chp->parse_from_file("foo.chp");

# Find some fun facts about this chip

print $chp->algorithm_name()."\n";

print $chp->version()."\n";


# Print out all of the signal values for this chip

foreach my $i (keys %{$chp->probe_set_results()}) {
    print $i.",".$CHP->probe_set_results()->{$i}->{"Signal"}."\n";
}



=head1 DESCRIPTION

The Affymetrix microarray system produces files in a variety of
formats. If this means nothing to you, these modules are probably not
for you :). This module parses CHP files. 

This module requires a Bio::Affymetrix::CDF object before it can do
anything. This must be supplied to the constructor. See the perldoc
for that to see how to use that module. The module can parse various
types of CHP file transparently. You can find out what type you have
by using the version() method.
    
All of the Bio::Affymetrix modules parse a file entirely into
memory. You therefore need enough memory to hold these objects. For
some applications, parsing as a stream may be more appropriate-
hopefully the source to these modules will give enough clues to make
this an easy task. 

=head2 HINTS

You fill the object filled with data using the
parse_from_filehandle, parse_from_string or parse_from_file
routines. You can get/set various statistics  using methods on the
object. Data is retrieved as a giant hash from
probe_set_results. Subroutines marked "original_" give values as they
are claimed in the original file, not as they are now (for instance if
you modify the value) 

=head1 NOTES

=head2 REFERENCE

Modules were written with the official Affymetrix documentation, which
can be located at http://www.affymetrix.com/support/developer/AffxFileFormats.ZIP

=head2 COMPATIBILITY

This module can parse the CHP files produced by the Affymetrix software
MAS 5 and GCOS v1.2. It can also process files produced by GCOS v1.0
in theory. However the authors of this module have never actually
seen an actual GCOS v1.0 file, and so we rely on the specification
supplied by Affymetrix only. If you have GCOS v1.0 files, feedback
as to whether the code actually works is welcome.

Whatever file format you use the module should work transparently.

These modules are focused on GCOS v1.2 CHP files. The MAS5 CHP
files actually contain a lot of extra information that is not
displayed in MAS5 or GCOS. This information is thrown away by the
parser.

This module can only do expression arrays.

=head1 TODO

Writing CHP files as well as reading them.

=head1 COPYRIGHT

Copyright (C) 2005 by Nick James, David J Craigon, NASC (arabidopsis.info), The
University of Nottingham

This module is free software. You can copy or redistribute it under the same terms as Perl itself. 

Affymetrix is a registered trademark of Affymetrix Inc., Santa
Clara, California, USA.

=head1 AUTHORS
    
Nick James (nick at arabidopsis.info)

David J Craigon (david at arabidopsis.info)

Nottingham Arabidopsis Stock Centre (http://arabidopsis.info), University of Nottingham.

=head1 METHODS

=cut


use strict;

our $VERSION=0.3;

# Module for processing CHP files


=head2 new

  Arg [1]    : Bio::Affymetrix::CDF $db_file
  Example    : my $chp=new Bio::Affymetrix::CHP($cdf);
  Description: constructor for CHP object
  Returntype : new Bio::Affmetrix::CHP object
  Exceptions : none
  Caller     : general

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto)||$proto;
    my $self  = {};

    $self->{"cdf"}=shift;

    bless ($self, $class);          # reconsecrate
    return $self;
}

# Getter/setter routines

# CDF object associated with this file


=head2 CDF

  Arg [1]    : Bio::Affymetrix::CDF $db_file
  Example    : none
  Description: get/set for CDF file associated with this CHP file. The db is the one that 
               belongs to the external_name.  
  Returntype : Bio::Affymetrix::CDF object
  Exceptions : none
  Caller     : general

=cut

sub CDF {
    my $self=shift;

    if (my $q=shift) {
	$self->{"cdf"}=$q;
    }
    return $self->{"cdf"};
}


# File format. Either XDA or MAS5 at the moment

=head2 original_format

  Arg [0]    : 	none
  Example    : 	my $format=$chp->original_format()
  Description: 	Returns the format of the CHP file parsed
  			 	(currently) either "XDA" (which is a GCOS v1.2 format,
				also known as version 4) or "MAS5" (which is produced
				either by MAS 5 or GCOS v1.0, also known as version 3)
  Returntype : string ("XDA" or "MAS5")
  Exceptions : none
  Caller     : general

=cut

sub original_format {
    my $self=shift;
    return $self->{"format"};
}

# Version of file (encoded in file)

=head2 original_version

  Arg [0]    : 	none
  Example    : 	my $version=$chp->original_version()
  Description: 	Returns the version of the CHP file parsed
  		Best used in conjunction with original_format,
		above. For XDA files, the version is always
		(currently) 1. For MAS5 files the version is either 12
		for a file produced by MAS5, or 13 for a GCOS v1.0
		file. Code is written for parsing version 13 files,
		but we've no idea if it works.

  Returntype : string
  Exceptions : none
  Caller     : general

=cut


sub original_version {
    my $self=shift;
    return $self->{"version"};
}

# Number of columns in the array

=head2 cols

  Arg [0]    : 	none
  Example    : 	my $x=$chp->cols()
  Description:	Numbers of columns in the array 
  Returntype :	integer
  Exceptions : 	none
  Caller     : 	general

=cut

sub cols {
    my $self=shift;

    if (my $q=shift) {
	$self->{"no_cols"}=$q;
    }
    return $self->{"no_cols"};
}


# Number of rows in the array

=head2 rows

  Arg [0]    : 	none
  Example    : 	my $y=$chp->rows()
  Description:	Get/set numbers of rows in the array 
  Returntype :	integer
  Exceptions : 	none
  Caller     : 	general

=cut

sub rows {
    my $self=shift;

    if (my $q=shift) {
	$self->{"no_rows"}=$q;
    }
    return $self->{"no_rows"};
}


# Number of probes claimed


=head2 original_number_of_probes

  Arg [0]    : 	none
  Example    : 	my $original_probes=$chp->original_number_of_probes()
  Description:	Gets the original number of probes reported in the
				array.

				The CHP files have the number of probes stored in
				them, and this function lets you read this number as
				it was stored in the file originally.

				A better way of finding out the current number of
				probes is to count the number in the probe_set_results
				hash, like so: scalar(keys %{$chp->probe_set_results()});
		
  Returntype :	integer
  Exceptions : 	none
  Caller     : 	general

=cut


sub original_number_of_probes {
    my $self=shift;
    return $self->{"no_units"};
}

# Number of qc units

=head2 original_number_qc_units

  Arg [0]    : 	none
  Example    : 	my $original_qc=$chp->original_number_qc_units()
  Description:	Gets the original number of QC units in the file.
  Returntype :	integer
  Exceptions : 	none
  Caller     : 	general

=cut


sub original_number_qc_units {
    my $self=shift;
    return $self->{"no_qc_units"};
}

# MS COM prog ID

=head2 original_com_progid

  Arg [0]    : 	none
  Example    : 	my $com_id=$chp->original_com_progid()
  Description:	Gets the progid of the orignal COM object that made
				this CHP file
  Returntype :	string
  Exceptions : 	none
  Caller     : 	general

=cut

sub original_com_progid {
    my $self=shift;
    return $self->{"com_progid"};
}

# CEL file name this CHP file originated from

=head2 CEL_file_name

  Arg [1]    : 	string $cel_file_name (optional)
  Example    : 	my $cel_file_name=$chp->CEL_file_name();
  Description:	Get/set the CEL file this CHP file was made from
  Returntype :	string
  Exceptions : 	none
  Caller     : 	general

=cut


sub CEL_file_name {
    my $self=shift;

    if (my $q=shift) {
	$self->{"cel_file_name"}=$q;
    }
    return $self->{"cel_file_name"};
}

# ATH1, etc.

=head2 probe_array_type

  Arg [1]    : 	string $array_type (optional)
  Example    : 	my $probe_array_type=$chp->probe_array_type();
  Description:	Get/set the Affymetrix chip type used in the
production of this CHP file. String is same format as CDF file name,
for example ATH1-121501
  Returntype :	string
  Exceptions : 	none
  Caller     : 	general

=cut


sub probe_array_type {
    my $self=shift;

    if (my $q=shift) {
	$self->{"probe_array_type"}=$q;
    }
    return $self->{"probe_array_type"};
}

# Algorithm name

=head2 algorithm_name

  Arg [1]    : 	string $algorithm_name (optional)
  Example    : 	my $algorithm_name=$chp->algorithm_name();
  Description:	Get/set the algorithm name that turned the CEL file
into this CHP file
  Returntype :	string
  Exceptions : 	none
  Caller     : 	general

=cut

sub algorithm_name {
    my $self=shift;

    if (my $q=shift) {
	$self->{"algorithm_name"}=$q;
    }
    return $self->{"algorithm_name"};
}


=head2 algorithm_version

  Arg [1]    : 	string $algorithm_version (optional)
  Example    : 	my $algorithm_version=$chp->algorithm_version();
  Description:	Get/set the algorithm version that turned the CEL file
into this CHP file
  Returntype :	string
  Exceptions : 	none
  Caller     : 	general

=cut


sub algorithm_version {
    my $self=shift;

    if (my $q=shift) {
	$self->{"algorithm_version"}=$q;
    }
    return $self->{"algorithm_version"};
}


# Algorithm params- returns hashref
=head2 algorithm_params

  Arg [1]    : 	hashref $algorithm_params (optional)
  Example    : 	my %algorithm_params=%{$chp->algorithm_params()};

# Print scale factor

print $algorithm_params("SF");

  Description:	Get/set the algorithm parameters for turning the CEL
file into this CHP file. Returns a reference to a hash, keyed on
parameter name.

Parameters include:
SF (scale factor)
Alpha1
Alpha2
Tau
NF (normalisation factor)


  Returntype :	hashref
  Exceptions : 	none
  Caller     : 	general

=cut

sub algorithm_params {
    my $self=shift;

    if (my $q=shift) {
	$self->{"algorithm_params"}=$q;
    }
    return $self->{"algorithm_params"};
}

# Summary Statistics- returns hashref


=head2 summary_statistics

  Arg [1]    : 	hashref $summary_statistics (optional)
  Example    : 	my %summary_statistics=%{$chp->summary_statistics()};

# Print RawQ

print $summary_statistics("RawQ");

  Description:	Get/set the summary statistics for turning the CEL
file into this CHP file. Returns a reference to a hash, keyed on
parameter name.

Parameters include:
RawQ
Noise
Background


  Returntype :	hashref
  Exceptions : 	none
  Caller     : 	general

=cut


sub summary_statistics {
    my $self=shift;

    if (my $q=shift) {
	$self->{"summary_statistics"}=$q;
    }
    return $self->{"summary_statistics"};
}

# Used in calculating background

=head2 smooth_factor

  Arg [1]    : 	float $smooth_factor (optional)
  Example    : 	my $smooth_factor=$chp->smooth_factor();
  Description:	Get/set the smooth factor. Your guess is as good as
mine as to what this actually is, although it is used in calculating
the background. Not available in MAS5 files.
  Returntype :	float
  Exceptions : 	none
  Caller     : 	general

=cut



sub smooth_factor {
    my $self=shift;

    if (my $q=shift) {
	$self->{"smooth_factor"}=$q;
    }
    return $self->{"smooth_factor"};
}

# An arrayref of zones

=head2 background_zones

  Arg [1]    : 	arrayref of arrayrefs $background_zones (optional)
  Example    : 	my @background_zones=@{$chp->background_zones()};

# Print "X", "Y", "Background Value" for background zone 0
print $background_zones[0]->[0],$background_zones[0]->[1],$background_zones[0]->[2];

  Description:	Get/set an array of background zones. Again, your guess is as good as
mine as to what this actually is, although it is used in calculating
the background. Not available in MAS5 files.

Returns an arrayref to an arrayref. Each zone has an array three
values long, which are X,Y and background value respectively.
  Returntype :	arrayref of arrayrefs
  Exceptions : 	none
  Caller     : 	general

=cut


sub background_zones {
    my $self=shift;

    if (my $q=shift) {
	$self->{"zones"}=$q;
    }

    return $self->{"zones"};
}

# The hash of results

=head2 probe_set_results

  Arg [1]    : 	hashref of hashrefs $probe_set_results (optional)
  Example    : 	my %results=%{$chp->probe_set_results()};
e
# Print "Signal", "Detection Call", "StatPairsUsed" for my favourite probe

print ($results{"246310_at"}->{"Signal"}."\n".$results{"246310_at"}->{"DetectionCall"}."\n".$results{"246310_at"}->{"StatPairsUsed"}."\n");

  Description:	Gain access to the actual data. Returns a reference to
hash, keyed on probe name. Each value contains another reference
to a hash with the following keys:

Signal
DetectionCall (detection call- one of P M A N)
DetectionPValue
StatPairs
StatPairsUsed
Probeset (a Bio::CDF::ProbeSet object, q.v.)

and optionally:
Change
ChangePValue
SignalLogRatio
SignalLogRatioHigh
SignalLogRatioLow
CommonPairs

when it is a CHP files with a comparison in it.


  Returntype :	hashref of hashrefs
  Exceptions : 	none
  Caller     : 	general

=cut


sub probe_set_results {
    my $self=shift;

    if (my $q=shift) {
	$self->{"probe_set_results"}=$q;
    }

    return $self->{"probe_set_results"};
}


# Parsing
=head2 parse_from_string

  Arg [1]    : 	string
  Example    : 	$chp->parse_from_string($chp_file_in_a_string);
  Description:	Parse a CHP file from a buffer in memory
  Returntype :	none
  Exceptions : 	none
  Caller     : 	general

=cut

sub parse_from_string {
    my $self=shift;
    my $string=shift;


    open CHP,"<",\$string or die "Cannot open string stream";

    $self->parse_from_filehandle(\*CHP);

    close CHP;
}

=head2 parse_from_file

  Arg [1]    : 	string
  Example    : 	$chp->parse_from_file($chp_filename);
  Description:	Parse a CHP file from a file
  Returntype :	none
  Exceptions : 	dies if can't open file
  Caller     : 	general

=cut


sub parse_from_file {
    my $self=shift;
    my $filename=shift;

    open CHP,"<".$filename or die "Cannot open file ".$filename;

    $self->parse_from_filehandle(\*CHP);

    close CHP;
}

=head2 parse_from_filehandle

  Arg [1]    : 	reference to filehandle
  Example    : 	$chp->parse_from_filehandle(\*STDIN);
  Description:	Parse a CHP file from a filehandle
  Returntype :	none
  Exceptions : 	none
  Caller     : 	general

=cut


sub parse_from_filehandle {
    my $self=shift;
    my $fh=shift;

    binmode $fh;
    
    # First step- detect whether it's a GCOS or MAS5 file
    
    # A buffer for reading things into
    my $buffer; 

    # XDA files have their first feature as a magic number, 65

    read ($fh, $buffer, 4);
    my $magic_number = unpack("V", $buffer);

    if ($magic_number==65) {
	# It's a GCOS v1.2 "v4 file", XDA file! Hurrah!
	$self->_parse_xda($fh);
	return;
    }

    # MAS5 files have their first feature as a string

    read ($fh, $buffer, 18, 4);
    
    $magic_number=unpack("A22",$buffer);

    if ($magic_number eq "GeneChip Sequence File") {
	# It's a MAS5/GCOS v1.0 "v3 file"! Yippee!
	$self->_parse_mas5($fh);
	return;
    }

    die "This doesn't look like a CHP file to me. I can only understand certain CHP filetypes, however\n";
}

sub _parse_xda {
    my ($self,$fh) = @_;

    $self->{"format"}="XDA";
    
    my $buffer; 

    # First some trivia

    read ($fh, $buffer, 4);
    $self->{"version"}= unpack ("V", $buffer);
    
    if ($self->{"version"}!=1) {
	warn "This CHP file is newer than the software parsing them. Results may be suspect."; # die here, perhaps?
    }

    read ($fh, $buffer, 12);
    ($self->{"no_cols"},$self->{"no_rows"},$self->{"no_units"},$self->{"no_qc_units"})= unpack ("S2V2", $buffer);

    read ($fh, $buffer, 4);
    
    $self->{"chip_type"}=unpack ("V", $buffer);

    if ($self->{"chip_type"}!=0) {
	die "This software does not process non-expression arrays";
    }
    
    $self->{"com_progid"}=$self->unpack_length_string($fh);
    
    $self->{"cel_file_name"}=$self->unpack_length_string($fh);

    $self->{"probe_array_type"}=$self->unpack_length_string($fh);

    $self->{"algorithm_name"}=$self->unpack_length_string($fh);

    $self->{"algorithm_version"}=$self->unpack_length_string($fh);

    # Algorithm parameters
    
    {
	read ($fh, $buffer, 4);
	my $no_algorithm_params = unpack ("V", $buffer);

	# get varying number of parameter names and values and read into hash 
	my %algorithm_params; 
	for (my $i=0;$i<$no_algorithm_params;$i++) {
	    my $name=$self->unpack_length_string($fh);
	    my $value=$self->unpack_length_string($fh);
	    $algorithm_params{$name}=$value;
	}

	$self->{"algorithm_params"}=\%algorithm_params;
    }

    # Summary statistics

    {
	read ($fh, $buffer, 4);
	my $no_stats = unpack ("V", $buffer);

	# get varying number of parameter names and values and read into hash 
	my %h;
	for (my $i=0;$i<$no_stats;$i++) {
	    my $name=$self->unpack_length_string($fh);
	    my $value=$self->unpack_length_string($fh);
	    # Strip trailing space
	    $value=~s/\s*$//o;
	    $h{$name}=$value;
	}

	$self->{"summary_statistics"}=\%h;
    }

    # Background calculation

    {
	read ($fh, $buffer, 8);
	my $m;
	($m,$self->{"smooth_factor"}) = unpack ("Vf", $buffer);
	
	$self->{"zones"}=[];

	my %zone_info; 
	for (my $i=0;$i<$m;$i++) {
	    read ($fh, $buffer, 12);
	    my @zone = unpack ("f3", $buffer);
	    push @{$self->{"zones"}},\@zone;
	}
    }

    # Actual data. This is the bit that would need to be added to, if we did SNP etc. arrays

    {
	my $size;
	read ($fh, $buffer, 5);
	($self->{"analysis_type"},$size)=unpack("CV", $buffer);

	my %data;

	my $probesetlist=$self->{"cdf"}->probesets();

	foreach my $i (sort(keys(%$probesetlist))) {
	    read ($fh, $buffer, $size);
	    
	    # Non-comparison analysis
	    
	    if ($self->{"analysis_type"}==0 || $self->{"analysis_type"}==2) {
		my @results=unpack("Cf2S2",$buffer);
		my %h;
		if ($results[0]==0) {
		    $h{"DetectionCall"}="P";
		} elsif ($results[0]==1) {
		    $h{"DetectionCall"}="M";
		} elsif ($results[0]==2) {
		    $h{"DetectionCall"}="A";
		} elsif ($results[0]==3) {
		    $h{"DetectionCall"}="N";
		}
		$h{"DetectionPValue"}=$results[1];
		$h{"Signal"}=$results[2];
		$h{"StatPairs"}=$results[3];
		$h{"StatPairsUsed"}=$results[4];

		$h{"Probeset"}=$probesetlist->{$i};

		$data{$probesetlist->{$i}->name()}=\%h;

	    } else {
		# Comparison analysis
		$self->{"comparison"}=1;
		my @results=unpack("Cf2S2Cf4S",$buffer);
		my %h;
		if ($results[0]==0) {
		    $h{"DetectionCall"}="P";
		} elsif ($results[0]==1) {
		    $h{"DetectionCall"}="M";
		} elsif ($results[0]==2) {
		    $h{"DetectionCall"}="A";
		} elsif ($results[0]==3) {
		    $h{"DetectionCall"}="N";
		}
		$h{"DetectionPValue"}=$results[1];
		$h{"Signal"}=$results[2];
		$h{"StatPairs"}=$results[3];
		$h{"StatPairsUsed"}=$results[4];
		$h{"Change"}=$results[6];
		$h{"ChangePValue"}=$results[7];
		$h{"SignalLogRatio"}=$results[8];
		$h{"SignalLogRatioLow"}=$results[9];
		$h{"SignalLogRatioHigh"}=$results[10];
		$h{"CommonPairs"}=$results[11];

		$h{"Probeset"}=$probesetlist->[$i];

		$data{$probesetlist->{$i}->name()}=\%h;
	    }
	}
	$self->{"probe_set_results"}=\%data;
    }
}





sub _parse_mas5 {
    my ($self,$fh) = @_;

    $self->{"format"}="MAS5";

    my $buffer; 
    
    # Get version from file
    read ($fh, $buffer, 4);
    $self->{"version"}=unpack ("V", $buffer);

    if ($self->{"version"}!=12&&$self->{"version"}!=13) {
	warn "This CHP file has a version number unrecognised by the software parsing them. Results may be suspect."; # die here, perhaps?
    }

    if ($self->{"version"}==13) {
	warn "The authors of this module have never seen a genuine GCOS v1.0 CHP file. This program can parse them, but we're only relying on the specification supplied by Affymetrix- we've not tested this at all. Suspect results therefore are highly likely.";
    }
    # Trivia section

    $self->{"algorithm_name"}=$self->unpack_length_string($fh);

    $self->{"algorithm_version"}=$self->unpack_length_string($fh);

    
    # Parse algorithm parameters to maintain compatability with XDA format

    {
	my %algorithm_params;
	my $parse_me=$self->unpack_length_string($fh);
	foreach my $i (split / /,$parse_me) {
	    my ($name,$value)=split /=/,$i;
	    $algorithm_params{$name}=$value;
	}

	$self->{"algorithm_params"}=\%algorithm_params;
    }

    # Summary statistics

    {
	my %summary_stats;
	my $parse_me=$self->unpack_length_string($fh);
	foreach my $i (split / /,$parse_me) {
	    my ($name,$value)=split /=/,$i;
	    $summary_stats{$name}=$value;
	}

	$self->{"summary_statistics"}=\%summary_stats;
    }

    read ($fh, $buffer, 20);
    my $max_probeset_num;
    ($self->{"no_rows"},$self->{"no_cols"},$self->{"no_units"},$max_probeset_num,$self->{"no_qc_units"})= unpack ("V5", $buffer);
    
    # THROW AWAY PROBESET NUMBER FOR EACH PROBESET
    read ($fh, $buffer, 4*$self->{"no_units"});

    # THROW AWAY NUMBER OF PROBE PAIRS FOR EACH PROBESET
    read ($fh, $buffer, 4*$max_probeset_num);

    # THROW AWAY PROBESETTYPE FOR EACH PROBESET
    read ($fh, $buffer, 4*$max_probeset_num); # Should test

    # THROW AWAY PROBESET NUMBER FOR EACH PROBESET
    read ($fh, $buffer, 4*$self->{"no_units"});

    read ($fh, $buffer, 512);
    ($self->{"probe_array_type"},$self->{"cel_file_name"})=unpack ("Z256Z256",$buffer);

    if ($self->{"probe_array_type"} ne $self->{"cdf"}->name()) {
	warn "The CDF object you have supplied does not have the same name as the CDF file used to make this CHP file. Results may be dubious";
    }

    $self->{"com_progid"}=$self->unpack_length_string($fh);

    # Actual data. This is the bit that would need to be added to, if we did SNP etc. arrays
    {
	my %data;
	
	if ($self->{"version"}==12) {
	    
	    my %results;
	    
	    my $probesetlist=$self->{"cdf"}->probesets();
	    
	    foreach my $i (sort(keys(%$probesetlist))) {

		# Non-comparison analysis

		read ($fh, $buffer, 44);
		
		my @results=unpack("V7f3V", $buffer);

		my %h;

		if ($results[10]==0) {
		    $h{"DetectionCall"}="P";
		} elsif ($results[10]==1) {
		    $h{"DetectionCall"}="M";
		} elsif ($results[10]==2) {
		    $h{"DetectionCall"}="A";
		} elsif ($results[10]==3) {
		    $h{"DetectionCall"}="N";
		}

		$h{"DetectionPValue"}=$results[7];
		$h{"Signal"}=$results[9];
		$h{"StatPairs"}=$results[0];
		$h{"StatPairsUsed"}=$results[1];
		$h{"Probeset"}=$probesetlist->{$i};

		# Blimey-o-reilly! There's an entire CEL file in here! Let's ditch that.
		
		read ($fh, $buffer, $h{"StatPairs"}*52); #52 bytes of junk per probeset?

		read ($fh, $buffer, 4);
		
		# Comparison analysis

		if (unpack("V",$buffer)==1) {
			$self->{"comparison"}=1;
		    read ($fh, $buffer, 58);
		    my @results=unpack("V5c2V9",$buffer);

		    my %h;
		    $h{"Change"}=$results[4];
		    $h{"ChangePValue"}=$results[15]/1000;
		    $h{"SignalLogRatio"}=$results[12]/1000;
		    $h{"SignalLogRatioLow"}=$results[14]/1000;
		    $h{"SignalLogRatioHigh"}=$results[9]/1000;
		    $h{"CommonPairs"}=$results[0];
		    $h{"BaselineAbsent"}=$results[5];
		    $h{"Probeset"}=$probesetlist->[$i];
		}
		
#		$probesetlist->[$i] or die "Suspect CDF file! We have more data in the CHP file than expected. Are you using the right CDF file?";
		
		$data{$probesetlist->{$i}->name()}=\%h;
		
	    }
	} elsif ($self->{"version"}==13) {
	    
	    my %results;
	    
	    my $probesetlist=$self->{"cdf"}->probesets();
	    
	    for (my $i=0;$i<$self->{"no_units"};$i++) {

		# Non-comparison analysis

		read ($fh, $buffer, 24);
		
		my @results=unpack("V3f2V", $buffer);

		my %h;
		if ($results[5]==0) {
		    $h{"DetectionCall"}="P";
		} elsif ($results[5]==1) {
		    $h{"DetectionCall"}="M";
		} elsif ($results[5]==2) {
		    $h{"DetectionCall"}="A";
		} elsif ($results[5]==3) {
		    $h{"DetectionCall"}="N";
		}


		$h{"DetectionPValue"}=$results[3];
		$h{"Signal"}=$results[4];
		$h{"StatPairs"}=$results[0];
		$h{"StatPairsUsed"}=$results[1];
		$h{"Probeset"}=$probesetlist->[$i];

		# Blimey-o-reilly! There's still-enough-of-a-CEL-file in here to be annoying! Nurse! The screens!
		
		read ($fh, $buffer, $h{"StatPairs"}*20); #20 bytes of junk per probeset?

		read ($fh, $buffer, 4);
		
		# Comparison analysis

		if (unpack("V",$buffer)==1) {
		    read ($fh, $buffer, 27); #????????
		    my @results=unpack("V2cV4",$buffer);

		    my %h;
		    $h{"Change"}=$results[1];
		    $h{"ChangePValue"}=$results[6];
		    $h{"SignalLogRatio"}=$results[3]/1000;
		    $h{"SignalLogRatioLow"}=$results[4]/1000;
		    $h{"SignalLogRatioHigh"}=$results[5]/1000;
		    $h{"CommonPairs"}=$results[0];
		    $h{"BaselineAbsent"}=$results[2];

		    $h{"Probeset"}=$probesetlist->[$i];
		}
		
		$probesetlist->[$i] or die "Suspect CDF file! We have more data in the CHP file than expected. Are you using the right CDF file?";
		
		$data{$probesetlist->[$i]->name()}=\%h;
		
	    }
	}

	$self->{"probe_set_results"}=\%data;
    }
}



# binary file utility to read a length-defined string

sub unpack_length_string {
    my $self=shift;
    my $fh=shift;
    
    my $buffer;

    read ($fh, $buffer, 4);
    my $len = unpack ("V", $buffer);
    read ($fh, $buffer, $len);

    return unpack("a".$len,$buffer);

}


1;
