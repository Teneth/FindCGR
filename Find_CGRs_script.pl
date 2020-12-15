#!/usr/bin/perl -w
# usage :  perl find_cpgs.pl 150 0.55 chr01.fa chr01
# the script runs on only one chromosome at a time, and won’t search masked (lowercase) sequence in the FASTA file.
#
#The command above will use a window size of 150 kb and a ratio threshold of 0.55, where the ratio is:
# of CG dinucleotides / ( window size / 16)

use strict;
use warnings;

my $window_size     = $ARGV[0];
my $ratio_threshold = $ARGV[1];
my $fasta_file      = $ARGV[2];
my $chrom_prefix    = $ARGV[3];
my $base_num_offset = $ARGV[4];  # e.g., if FASTA doesn't start at chrom start

$base_num_offset = defined $base_num_offset ? $base_num_offset : 0;

open my $SEQ, '<', $fasta_file or die $!;

my $sequence = '';

while (my $line = <$SEQ>) {
    chomp $line;
    if ($line !~ m/^>/) {
        $sequence .= $line;
    }
}

for (my $base = 0; $base <= length($sequence) - $window_size; $base++) {
    my $sub_sequence = substr($sequence, $base, $window_size);
    my $num_CG_dinucleotides =()= $sub_sequence =~ /CG/g;

    my $ratio = $num_CG_dinucleotides / ($window_size / 16);

    if ($ratio > $ratio_threshold) {
        printf("%s\t%d\t%d\t%0.3g\n", $chrom_prefix, $base + $base_num_offset, $base + $window_size + $base_num_offset, $ratio) ;
    }
}
