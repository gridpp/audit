#!/usr/bin/perl
use strict;

use Getopt::Long;

# Prototypes
sub initParams();

# Global options
my %parameter;

#-------------------------------------

# Read the options
initParams();

my $serviceLevel = $parameter{SERVICELEVEL};
my $selectionStart = $parameter{STARTEPOCH};
my $selectionEnd = $parameter{ENDEPOCH};

my $hs06ServiceLevel = $serviceLevel / 250;

my $file = $parameter{INPUT};
open(FILE,"$file") or die("No open file $file\n");
while(<FILE>) {
  my $line = $_; chomp($line);
  if ($line =~ /;E;/) {
    $line =~ /start=(\d+).*owner=(\S+).*end=(\d+)/;
    my $recordStart = $1;
    my $owner       = $2;
    my $recordEnd = $3;
    if ( ($recordEnd >= $selectionStart) && ($recordEnd < $selectionEnd)) {
      # Good; we have found a record in the right time frame. But does the 
      # owner match one of our owner bits?
      my $selected = 0;

      if ($#{$parameter{'OWNERBITS'}} < 0) {
        # None defined so it's automatically selected
        $selected = 1;
      }
      else {
        for my $ownerPart (@{$parameter{'OWNERBITS'}}) {
          if ($owner =~ /$ownerPart/) {
            $selected = 1;
          }
        }
      }
      if ($selected) {
        my $wallHs06Hours = -1;
        if ($line =~ /resources_used.walltime=(\d+):(\d+):(\d+)/) {
          my $hour = $1; my $min = $2; my $sec = $3;
          $wallHs06Hours = ($hour + $min/60 + $sec/60/60 ) * $hs06ServiceLevel ;
        }
      
        my $cpuHs06Hours = -1;
        if ($line =~ /resources_used.cput=(\d+):(\d+):(\d+)/) {
          my $hour = $1; my $min = $2; my $sec = $3;
          $cpuHs06Hours = ( $hour + $min/60 + $sec/60/60 ) * $hs06ServiceLevel ;
        }
      
        my $processors=1;
        if ($line =~ /Resource_List.ncpus=(\d+)/) {
          $processors = $1;
        }
        my $starttime=0;
        if ($line =~ /start=(\d+)/) {
          $starttime = $1;
        }
        my $endtime=0;
        if ($line =~ /end=(\d+)/) {
          $endtime = $1;
        }
        my $rawWallClockSecs = $endtime - $starttime;
        print("wallHs06Hours: $wallHs06Hours, cpuHs06Hours: $cpuHs06Hours, processors: $processors, rawWallClockSecs: $rawWallClockSecs\n");
      }
    }
  }
}
close(FILE);

#---------------------------------------------
# Read the command line options
#---------------------------------------------
sub initParams() {

  # Can accept a set of DNs (or parts of DNs)
  $parameter{'OWNERBITS'} = [];

  # Read the options
  GetOptions ('h|help'          =>   \$parameter{'HELP'},
              'se|startepoch:i' =>   \$parameter{'STARTEPOCH'} ,
              'ee|endepoch:i',  =>   \$parameter{'ENDEPOCH'} ,
              'sl|servicelevel:i',  =>   \$parameter{'SERVICELEVEL'} ,
              'i|inputfile:s',  =>   \$parameter{'INPUT'} ,
              'o|owner:s',       =>    $parameter{'OWNERBITS'} ,
              );

  if (defined($parameter{'HELP'})) {
    print <<TEXT;

Abstract: 

  -h  --help                       Prints this help page
  -se --startepoch   1475280000    Only select records on or after this epoch
  -ee --endepoch     1477958400    Only select records before this epoch
  -i  --inputfile    file          A file to test and print
  -o  --owner        pilatl        Prefix of an owner. Can add several of this option

Example:
  ./testAndPrintTorque.pl -i someFile  -o prdatl -o pilatl -se 1475280000 -ee 1477958400

TEXT
    exit(0);
  }
  if (!(defined($parameter{'INPUT'}))) { die ("You need to give an input file\n"); }
  if (!(defined($parameter{'STARTEPOCH'}))) { die ("You need to give a start epoch\n"); }
  if (!(defined($parameter{'ENDEPOCH'}))) { die ("You need to give an end epoch\n"); }
  if (!(defined($parameter{'SERVICELEVEL'}))) { die ("You need to give a service level\n"); }
}



#08/01/2016 10:16:27;E;10053102.hepgrid96.ph.liv.ac.uk;user=prdatl26 group=atlasprd jobname=cr101_689119320 queue=long ctime=1470037022 qtime=1470037022 etime=1470037022 start=1470042958 owner=prdatl26@hepgrid97.ph.liv.ac.uk exec_host=r25-n20.ph.liv.ac.uk/11 Resource_List.cput=48:00:00 Resource_List.ncpus=1 Resource_List.neednodes=1 Resource_List.nodect=1 Resource_List.nodes=1 Resource_List.walltime=48:00:00 session=14164 end=1470042987 Exit_status=0 resources_used.cput=00:00:06 resources_used.mem=5180kb resources_used.vmem=34184kb resources_used.walltime=00:00:32

