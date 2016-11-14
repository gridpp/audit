#!/usr/bin/perl

use strict;

#wallHs06Hours: 4.57222222222222, cpuHs06Hours: 3.55
my $wallTot = 0.0;
my $cpuTot = 0.0;
while (<>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /wallHs06Hours: ([0-9\.]+), cpuHs06Hours: ([0-9\.]+)/) {
    $wallTot = $wallTot + $1;
    $cpuTot = $cpuTot + $2;
    #print("Wall total = $wallTot, Cpu total = $cpuTot\n");
  }  
  else {
    #print("dud\n");
  }
}
print("Wall total = $wallTot, Cpu total = $cpuTot\n");


