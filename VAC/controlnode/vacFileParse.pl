#!/usr/bin/perl
use strict;
#-# APEL-individual-job-message: v0.3
#-# Site: UKI-NORTHGRID-LIV-HEP
#-# SubmitHost: vachammer.ph.liv.ac.uk/vac-r23-n11.ph.liv.ac.uk
#-# LocalJobId: a9544069-cf94-4faf-b3fc-4260f1dc86c2
#-# LocalUserId: r23-n11.ph.liv.ac.uk
#-# Queue: atlas
#-# GlobalUserName: /DC=uk/DC=ac/DC=liv/DC=ph/DC=vachammer
#-# FQAN: /atlas/Role=NULL/Capability=NULL
#-# WallDuration: 1271
#-# CpuDuration: 135
#-# Processors: 1
#-# NodeCount: 1
#-# InfrastructureDescription: APEL-VAC
#-# InfrastructureType: grid
#-# StartTime: 1470899942
#-# EndTime: 1470901213
#-# MemoryReal: 2097152
#-# MemoryVirtual: 2097152
#-# ServiceLevelType: HEPSPEC
#-# ServiceLevel: 10.6325
#-# %%

my $wallHs06Hours;
my $cpuHs06Hours;
my $wd;
my $sl;
my $cd;
my $p;
while(<>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /WallDuration: (\d+)/) { $wd = $1; }
  if ($line =~ /Processors: (\d+)/) { $p = $1; }
  if ($line =~ /CpuDuration: (\d+)/) { $cd = $1; }
  if ($line =~ /ServiceLevel: ([0-9\.]+)/) { $sl = $1; }
  if ($line =~ /^\%\%/) {
    $wallHs06Hours = $wd *  $sl * $p /60 /60;
    $cpuHs06Hours = $cd *  $sl * $p /60 /60;
    print("wallHs06Hours: $wallHs06Hours, cpuHs06Hours: $cpuHs06Hours, processors: $p\n")
  }
}
