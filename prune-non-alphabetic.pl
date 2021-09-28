#!/usr/bin/perl -w

# This simple script will delete from your text file all lines 
# containing more than 50% of non-alphabetic characters.
# It was originally written by Prof. Koichi Higuchi and shared 
# on the KH Coder forum.
# 
# Typical usage is:
# perl prune-non-alphabetic.pl /path/to/input.txt > /path/to/output.txt

use strict;
use warnings;

my $file = $ARGV[0];

unless (-e $file){
    print "no such file: $file\n";
    exit;
}

open my $fh, '<', $file or die;
while (<$fh>){
    chomp;
    my $length = length($_);
    next unless $length;
    my @alpha = ($_ =~ /[A-Z]/iog);
    if ( ($#alpha + 1) / length >= 0.5 ){
        print "$_\n";
    }
}
