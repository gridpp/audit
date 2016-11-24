#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Find;

# Prototypes
sub initParams();

# Global options
my %parameter;

#-------------------------------------

# Read the options
initParams();


#-- Main --

my $dir = $parameter{'DIRECTORY'};
my $start = $parameter{'STARTEPOCH'};
my $end = $parameter{'ENDEPOCH'};

find(\&wanted, $dir);

sub getEndTime(@) {
  my @lines = @_;
  foreach my $line (@lines) {
    chomp($line);
    if ($line =~ /EndTime: (\d+)/) {
      close(THEFILE);
      return $1;
    }
  }
  return -1;
}
# FQAN: /lhcb/Role=NULL/Capability=NULL
sub getFQAN(@) {
  my @lines = @_;
  foreach my $line (@lines) {
    chomp($line);
    if ($line =~ /FQAN: (\S+)/) {
      close(THEFILE);
      return $1;
    }
  }
  return '';
}

sub wanted {
  my $theFile = $File::Find::name;
  if ( -f $theFile) {
    open(FH, $theFile) or die("No open  $theFile\n");
    my @lines = <FH> ;
    close(FH);
    my $endTime = getEndTime(@lines);
    if (($endTime >= $start) && ($endTime < $end)) {
      my $selected = 0;
      if ($#{$parameter{'FQANBITS'}} <  0) {
        $selected = 1;
      }
      else {
        for my $partOfFQAN (@{$parameter{'FQANBITS'}}) {
          my $fqanInFile = getFQAN(@lines);
          if ($fqanInFile =~ /$partOfFQAN/) {
            $selected = 1;
          }
        }
      }
      if ($selected) {
        my $wallHs06Hours;
        my $cpuHs06Hours;
        my $wd;
        my $sl;
        my $cd;
        my $p;
        foreach my $line (@lines) {
          chomp($line);
          if ($line =~ /WallDuration: (\d+)/) { $wd = $1; }
          if ($line =~ /Processors: (\d+)/) { $p = $1; }
          if ($line =~ /CpuDuration: (\d+)/) { $cd = $1; }
          if ($line =~ /ServiceLevel: ([0-9\.]+)/) { $sl = $1; }
          if ($line =~ /^\%\%/) {
            #$wallHs06Hours = $wd *  $sl * $p /60 /60;
            #$cpuHs06Hours = $cd *  $sl * $p /60 /60;
            #print("wallHs06Hours: $wallHs06Hours, cpuHs06Hours: $cpuHs06Hours, processors: $p\n")
            print("WallDuration: $wd, CpuDuration: $cd, processors: $p\n")
          }
        }
      }
    }
  }
}

#---------------------------------------------
# Read the command line options
#---------------------------------------------
sub initParams() {

  # Can accept a set of FQANs (or parts of FQANs)
  $parameter{'FQANBITS'} = [];

  # Read the options
  GetOptions ('h|help'           =>   \$parameter{'HELP'},
              'dir|directory:s'  =>   \$parameter{'DIRECTORY'} ,
              'se|startepoch:i'  =>   \$parameter{'STARTEPOCH'},
              'ee|endepoch:i'    =>   \$parameter{'ENDEPOCH'},
              'f|fqan:s'         =>    $parameter{'FQANBITS'} ,
              );

  if (defined($parameter{'HELP'})) {
    print <<TEXT;

Abstract: A tool to audit accounts

  -h  --help                       Prints this help page
  -se --startepoch  1475280000     Start epoch
  -ee --endepoch    1477958400     End epoch
  -f  --fqan        part of fqan   Some part of the fqan, can be several on one line

Example:
  ./testAndPrintVAC.pl -se 1475280000 -ee 1477958400 -fqan lhcb -fqan atlas -dir /var/lib/vac/apel-archive 

TEXT
    exit(0);
  }

  if (!(defined($parameter{'DIRECTORY'}))) { die ("You need to give an input directory\n"); }
  if (!(defined($parameter{'STARTEPOCH'}))) { die ("You need to give a start epoch\n"); }
  if (!(defined($parameter{'ENDEPOCH'}))) { die ("You need to give an end epoch\n"); }
}


