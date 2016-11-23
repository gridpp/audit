#!/usr/bin/perl

use strict;

#wallHs06Hours: 4.57222222222222, cpuHs06Hours: 3.55
my $wallTot = 0.0;
my $cpuTot = 0.0;
my $rawWallClockSecsTot = 0.0;

while (<>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /wallHs06Hours:\s*([0-9\.]+), cpuHs06Hours:\s*([0-9\.]+)/) {
    my $w = $1;
    my $c = $2;
    my $processors = 1;
    if ($line =~ /processors:\s*([0-9\.]+)/) {
      $processors = $1;
    }
    $w = $w * $processors;
    $c = $c * $processors;
    $wallTot = $wallTot + $w;
    $cpuTot = $cpuTot + $c;
  }
  if ($line =~ /rawWallClockSecs:\s*([0-9\.]+)/) {
    my $rwc = $1;
    $rawWallClockSecsTot = $rawWallClockSecsTot + $rwc;
  }
}
print("Wall total = $wallTot, Cpu total = $cpuTot, Raw wall secs total = $rawWallClockSecsTot\n");

