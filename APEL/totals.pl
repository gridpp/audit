#!/usr/bin/perl
use strict;

die ("Please give a file and a ce (stem)") unless($#ARGV==1);
my $file = shift();
my $ce   = shift();
open(FILE,"$file") or die("Can't open that file.");
my @accumulators;
while(<FILE>) {
  my $line = $_;
  chomp($line);
  $line =~ s/\r//g;
  if ($line =~ /$ce/) {
    my @parts = split(/\s*,\s*/,$line);
    my $ii=-1;
    foreach my $p (@parts) {
      $ii++;
      if ($p =~ /^([0-9\.\%]+)$/) {
        my $value = $1;
        $accumulators[$ii] = $accumulators[$ii] + $value;
      }
    }
  }
}
close(FILE);
print("Numeric column totals:\n");
foreach my $tot (@accumulators) {
  print("  $tot  ");
}
print("\n");

