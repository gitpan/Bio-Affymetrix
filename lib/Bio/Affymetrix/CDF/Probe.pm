#!/usr/bin/perl

# A Affymetrix probeset. We gloss over the fact that multiple
# Unit_blocks are allowed per Unit, since this whole set of modules
# only really cares about expression

# No docs written as yet. Copyright and License as Probeset.pm

package CDF::Probe;

use warnings;
use strict;
our $VERSION=0.1;


sub new {
    my $class=shift;
    my $q=shift;
    my $self={};

    bless $self,$class;


    return $self;
}

# Getter/setters

# Probe info

# Coordinates of probe

sub x {
    my $self=shift;
    
    if (my $q=shift) {
	$self->{"X"}=$q;
    }
    
    return $self->{"X"};
}

sub y {
    my $self=shift;
    
    if (my $q=shift) {
	$self->{"Y"}=$q;
    }
    
    return $self->{"Y"};
}

# Probeset the probe came out of (name)

sub original_probeset {
    my $self=shift;
    return $self->{"PROBESET"};
}

# The number of the probe in the probeset

sub original_probe_number {
    my $self=shift;
    return $self->{"EXPOS"};
}



# Position of the mismatched base

sub mismatch_position {
    my $self=shift;
    
    if (my $q=shift) {
	$self->{"POS"}=$q;
    }
    
    return $self->{"POS"};
}


# The base at the mismatch position

sub probe_mismatch_base {
    my $self=shift;
    
    if (my $q=shift) {
	$self->{"PBASE"}=$q;
    }
    
    return $self->{"PBASE"};
}

# What the base is to detect for the target sequence. Non-mismatch probes have probe_mismatch_base == probe_target_base

sub probe_target_base {
    my $self=shift;
    
    if (my $q=shift) {
	$self->{"PBASE"}=$q;
    }
    
    return $self->{"PBASE"};
}

# Is this probe a mismatch?

sub is_mismatch {
    my $self=shift;
    return !($self->probe_target_base() eq $self->probe_mismatch_base());
}

# Which probe pair is this?

sub probepair_number {
    my $self=shift;

    if (my $q=shift) {
	$self->{"ATOM"}=$q;
    }
    return $self->{"ATOM"};
}

# Index for CEL file, apparently

sub index {
    my $self=shift;

    if (my $q=shift) {
	$self->{"INDEX"}=$q;
    }
    return $self->{"INDEX"};
}

1;
