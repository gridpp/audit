#!/usr/bin/perl

use strict;

my $fileList = shift();
my $serviceLevel = shift();
my $selectionStart = shift();
my $selectionEnd = shift();

my $hs06ServiceLevel = $serviceLevel / 250;

open(FILELIST,"$fileList") or die("No open fileList $fileList\n");
while(<FILELIST>) {
  my $file = $_; chomp($file);
  open(FILE,"$file") or die("No open file $file\n");
  while(<FILE>) {
    my $line = $_; chomp($line);
    if ($line =~ /;E;/) {
      $line =~ /start=(\d+).*end=(\d+)/;
      my $recordStart = $1;
      my $recordEnd = $2;
      if ( ($recordEnd >= $selectionStart) && ($recordEnd < $selectionEnd)) {
        # Good; we have found a record in the right time frame. Let's take it apart to make 
        my $wallHs06Hours = -1;
        #$line =~ /(resources_used.walltime=\d+:\d+:\d+)/; my $debug = $1; print("DEBUGW: $debug\n");
        if ($line =~ /resources_used.walltime=(\d+):(\d+):(\d+)/) {
          my $hour = $1; my $min = $2; my $sec = $3;
          $wallHs06Hours = ($hour + $min/60 + $sec/60/60 ) * $hs06ServiceLevel ;
        }
     
        my $cpuHs06Hours = -1;
        #$line =~ /(resources_used.cput=\d+:\d+:\d+)/; my $debug = $1; print("DEBUGC: $debug\n");
        if ($line =~ /resources_used.cput=(\d+):(\d+):(\d+)/) {
          my $hour = $1; my $min = $2; my $sec = $3;
          $cpuHs06Hours = ( $hour + $min/60 + $sec/60/60 ) * $hs06ServiceLevel ;
        }

        print("wallHs06Hours: $wallHs06Hours, cpuHs06Hours: $cpuHs06Hours\n");
      }
    }
  }
  close(FILE);
}
close(FILELIST);


#08/01/2016 10:16:27;E;10053102.hepgrid96.ph.liv.ac.uk;user=prdatl26 group=atlasprd jobname=cr101_689119320 queue=long ctime=1470037022 qtime=1470037022 etime=1470037022 start=1470042958 owner=prdatl26@hepgrid97.ph.liv.ac.uk exec_host=r25-n20.ph.liv.ac.uk/11 Resource_List.cput=48:00:00 Resource_List.ncpus=1 Resource_List.neednodes=1 Resource_List.nodect=1 Resource_List.nodes=1 Resource_List.walltime=48:00:00 session=14164 end=1470042987 Exit_status=0 resources_used.cput=00:00:06 resources_used.mem=5180kb resources_used.vmem=34184kb resources_used.walltime=00:00:32


