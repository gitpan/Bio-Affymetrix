#!/usr/bin/perl

# A package for parsing CDF files

# Docs come before the code

=head1 NAME

Bio::Affymetrix::CDF- parse Affymetrix CDF files

=head1 SYNOPSIS

use Bio::Affymetrix::CDF;

# Parse the CDF file

my $cdf=new CDF();

$cdf->parse_from_file("foo.cdf");

# Find some fun facts about this chip type

print $cdf->rows().",".$cdf->cols()."\n";

print $cdf->version()."\n";



# Print out all of the probeset names on this chip type

foreach my $i (@{$chp->probesets}) {
    print $i->name()."\n";
}

=head1 DESCRIPTION

The Affymetrix microarray system produces files in a variety of
formats. If this means nothing to you, these modules are probably not
for you :). This module parses CDF files. Use this module if you want
to find out about the design of an Affymetrix CHP, or you need the
object for another one of the modules in this package.

All of the Bio::Affymetrix modules parse a file entirely into
memory. You therefore need enough memory to hold these objects. For
some applications, parsing as a stream may be more appropriate-
hopefully the source to these modules will give enough clues to make
this an easy task. This module in particular takes a lot of memory if
probe information is also stored (about 150Mb). Memory usage is not too
onorous (about 15Mb) if probe level information is omitted.

=head2 HINTS

You fill the object filled with data using the
parse_from_filehandle, parse_from_string or parse_from_file
routines. You can get/set various statistics using methods on the
object.

The key method is probesets. This returns an array of
Bio::Affymetrix::CDF::Probeset objects. These contain data about the
probesets. 


=head1 NOTES

=head2 REFERENCE

Modules were written with the official Affymetrix documentation, which
can be located at http://www.affymetrix.com/support/developer/AffxFileFormats.ZIP

=head2 COMPATIBILITY

This module can parse the CDF files produced by the Affymetrix software
MAS 5 only. This is different from the Bio::Affymetrix::CHP
module. These files have QC information in them, which is thrown away.

=head1 TODO

Writing CDF files as well as reading them. Parsing GCOS v1.2 CDF
files. Maybe parse QC information?

=head1 COPYRIGHT

Copyright (C) 2004 by Nick James, David J Craigon, NASC, The
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


package Bio::Affymetrix::CDF;

use warnings;
use strict;
our $VERSION=0.1;

use Bio::Affymetrix::CDF::Probeset;

=head2 new

  Arg [0]    : none
  Example    : my $cdf=new Bio::Affymetrix::CDF();
  Description: constructor for CDF object
  Returntype : new Bio::Affmetrix::CDF object
  Exceptions : none
  Caller     : general

=cut

sub new {
    my $class=shift;
    my $q=shift;
    my $self={};

    $self->{"PROBESETS"}=[];

    bless $self,$class;
    return $self;
}

# Getter/setters

# CDF file trivia
=head2 original_version
  Arg [0]    : 	none
  Example    : 	my $version=$cdf->original_version()
  Description: 	Returns the version of the CDF file parsed. Encoded in file.
  Returntype : string
  Exceptions : none
  Caller     : general
=cut

sub original_version {
    my $self=shift;
    return $self->{"VERSION"};
}

=head2 original_format
  Arg [0]    : 	none
  Example    : 	my $format=$cdf->original_format()
  Description:	Returns the format of the CDF file parsed. Currently
MAS5 only
  Returntype : 	string ("MAS5")
  Exceptions : 	none
  Caller     : 	general

=cut


sub original_format {
    my $self=shift;
    return $self->{"FORMAT"};
}

# Chip name

=head2 name
  Arg [1]    : 	string $name (optional)
  Example    : 	my $name=$cdf->name()
  Description: 	Get/set the name of this chip type (e.g. ATH1-121501)
  Returntype : string
  Exceptions : none
  Caller     : general
=cut

sub name {
    my $self=shift;
    if (my $q=shift) {
	$self->{"NAME"}=$q;
    }
    return $self->{"NAME"};
}


=head2 rows
  Arg [1]    : 	integer $rows (optional)
  Example    : 	my $name=$cdf->rows()
  Description: 	Get/set the number of rows in this chip
  Returntype : integer
  Exceptions : none
  Caller     : general
=cut

sub rows {
    my $self=shift;
    if (my $q=shift) {
	$self->{"ROWS"}=$q;
    }
    return $self->{"ROWS"};
}

=head2 cols
  Arg [1]    : 	integer $cols (optional)
  Example    : 	my $name=$cdf->cols()
  Description: 	Get/set the number of cols in this chip
  Returntype : integer
  Exceptions : none
  Caller     : general
=cut

sub cols {
    my $self=shift;
    if (my $q=shift) {
	$self->{"COLS"}=$q;
    }
    return $self->{"COLS"};
}

=head2 probesets
  Arg [1]    : 	arrayref $probesets 
  Example    : 	my @probesets=@{$cdf->probesets()}
  Description: 	Get the probesets on the array
  Returntype : an reference to an array of
Bio::Affymetrix::CDF::Probeset objects (q.v.)
  Exceptions : none
  Caller     : general
=cut


sub probesets {
    my $self=shift;

    if (my $q=shift) {
	$self->{"PROBESETS"}=$q;
    }

    return $self->{"PROBESETS"};
}


# These are all named "original_" because they aren't calculated, they are what a parsed file claims

=head2 original_number_of_probes
  Arg [0]    : 	none
  Example    : 	my $number_of_probes=$cdf->original_number_of_probes()
  Description: 	Get the number of probesets on the array, as listed
originally in the file. A better way is to do my
$q=scalar(@{$cdf->probesets()}); if you want a current count.
  Returntype : integer
  Exceptions : none
  Caller     : general
=cut


sub original_number_of_probes {
    my $self=shift;
    return $self->{"NUMBEROFUNITS"};
}

=head2 original_max_unit
  Arg [0]    : 	none
  Example    : 	my $max_units=$cdf->original_max_units()
  Description: 	Get the max unit number in the CDF file. Fairly useless.
  Returntype : integer
  Exceptions : none
  Caller     : general
=cut

sub original_max_unit {
    my $self=shift;
    return $self->{"MAXUNIT"};
}

=head2 original_num_qc_units
  Arg [0]    : 	none
  Example    : 	my $max_units=$cdf->original_num_qc_units()
  Description: 	Get the number of QC units in the CDF file. Only piece
of QC information obtainable using this piece of software.
  Returntype : integer
  Exceptions : none
  Caller     : general
=cut


sub original_num_qc_units {
    my $self=shift;
    return $self->{"NUMQCUNITS"};
}

# PARSING ROUTINES

=head2 parse_from_string

  Arg [1]    : 	string
  Example    : 	$cdf->parse_from_string($cdf_file_in_a_string);
  Description:	Parse a CDF file from a buffer in memory
  Returntype :	none
  Exceptions : 	none
  Caller     : 	general

=cut


sub parse_from_string {
    my $self=shift;
    my $string=shift;


    open CDF,"<",\$string or die "Cannot open string stream";

    $self->parse_from_filehandle(\*CDF);

    close CDF;
}

=head2 parse_from_file

  Arg [1]    : 	string
  Example    : 	$cdf->parse_from_file($cdf_filename);
  Description:	Parse a CDF file from a file
  Returntype :	none
  Exceptions : 	dies if can't open file
  Caller     : 	general

=cut

sub parse_from_file {
    my $self=shift;
    my $filename=shift;

    open CDF,"<".$filename or die "Cannot open file ".$filename;

    $self->parse_from_filehandle(\*CDF);

    close CDF;
}

=head2 parse_from_filehandle

  Arg [1]    : 	reference to filehandle
  Example    : 	$cdf->parse_from_filehandle(\*STDIN);
  Description:	Parse a CDF file from a filehandle
  Returntype :	none
  Exceptions : 	none
  Caller     : 	general

=cut


sub parse_from_filehandle {
    my $self=shift;
    $self->{"FH"}=shift;
    binmode $self->{"FH"},":crlf";
    # Obtain file version, and do some rudimentary checking of information
    {
	my $i=$self->_next_line();

	if ($i ne "[CDF]") {
	    die "File does not look like a CDF file to me. Note- Bio::Affymetrix::CDF cannot understand all types CDF files";
	}

	$self->{"FORMAT"}="MAS5";

	$i=$self->_next_line();

	my ($name,$value)=$self->_split_line($i);

	if ($name ne "Version") {
	    die "File does not look like a CDF file to me";
	}

	if ($value ne "GC3.0") {
	    die "Can't understand any other type of CDF file other than GC3.0";
	}
	
	$self->{"VERSION"}=$value;
    }

    # Parse the rest of the file
    my $i=$self->_next_line();

    while (!eof $self->{"FH"}) {
	if ($i eq "[Chip]") {
	    $i=$self->_parse_chip_section();
	} elsif ($i=~/\[QC\d+\]/) {
	    $i=$self->_parse_qc_section();
	} elsif ($i=~/\[Unit\d+\]/) {
	    $i=$self->_parse_unit_section();
	}
	
    }
}


# Parsing bits of the CDF file 

sub _parse_chip_section {
    my $self=shift;
    my $i;
    while (!(($i=$self->_next_line())=~/^\[.*\]$/)) {
	my ($name,$value)=$self->_split_line($i);
	$self->{uc $name}=$value;
    }

    return $i;
}

sub _parse_qc_section {
    my $self=shift;

    my $i;

    while (!(($i=$self->_next_line())=~/^\[.*\]$/)) {
	# This version doesn't do anything with QC sections. They bore us.
	;
    }
    return $i;
}


sub _parse_unit_section {
    my $self=shift;
    
    my $i=new Bio::Affymetrix::CDF::Probeset;
    my $ret=$i->_parse_from_filehandle($self->{"FH"});
    
    $i->CDF($self);
    
    push @{$self->{"PROBESETS"}},$i;
    
    return $ret;
}



# General INI utility functions

sub _split_line {
    my $self=shift;
    my $line=shift;
    
    my @q=split /=/,$line,2;

    if (scalar(@q)!=2) {
	die "Can't parse line ".$line;
    }

    return @q;
}

# Sub that ignores blank lines

sub _next_line {
    my $self=shift;
    my $q;
    
    my $fh=$self->{"FH"};

    do {
	$q=<$fh>;
	chomp $q;
    } while (!eof $fh&&$q=~/^\s*$/);

    if (!eof $fh) {
	return $q;
    } else {
	return undef;
    }
}


1;
