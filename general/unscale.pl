#!/usr/bin/perl
use strict;

use Getopt::Long;

# Prototypes
sub initParams();

# Global options
my %parameter;

#-------------------------------------
#
#wallHs06Hours: 0.705555555555555, cpuHs06Hours: 0.1, processors: 1, host: slot1@r26-n03.ph.liv.ac.uk
#

# Read the options
initParams();

my %scalingTable;
open(SCALINGTABLE,"$parameter{'SCALINGTABLE'}") or die("No open scaling table $parameter{'SCALINGTABLE'}");
while(<SCALINGTABLE>) {
  my $line = $_;
  chomp($line);
  $line =~ s/#.*//;
  if ($line =~ /(\S+)\s+(\S+)/) {
    my $node = $1;
    my $factor = $2;
    $scalingTable{$node} = $factor;
  }
}
close(SCALINGTABLE);
open(INPUT,"$parameter{'INPUT'}") or die("No open input file $parameter{'INPUT'}");
while(<INPUT>) {
  my $line = $_;
  chomp($line);
  if ($line =~ /host:\s*(\S+)/) {
    my $node = $1;
    foreach my $n (keys(%scalingTable)) {
      if ($node =~ /$n/) {
        my $factor = $scalingTable{$n};
        my @parts = split(/[:,]/,$line );
        my $newWallHs06Hours = $parts[1]/$factor;
        my $newCpuHs06Hours  = $parts[3]/$factor;
        $line =~ s/wallHs06Hours: [0-9\.]+/wallHs06Hours: $newWallHs06Hours/;
        $line =~ s/cpuHs06Hours: [0-9\.]+/cpuHs06Hours: $newCpuHs06Hours/;
      }
    }
  }
  print $line,"\n";
}
close(INPUT);




#---------------------------------------------
# Read the command line options
#---------------------------------------------
sub initParams() {

  # Read the options
  GetOptions ('h|help'          =>   \$parameter{'HELP'},
              't|scalingtable:s',  =>   \$parameter{'SCALINGTABLE'} ,
              'i|inputfile:s',  =>   \$parameter{'INPUT'} ,
              );

  if (defined($parameter{'HELP'})) {
    print <<TEXT;

Abstract: blah blah blah

  -h  --help                       Prints this help page
  -i  --inputfile   file           File to unscale
  -t  --scalingtable tablefile     Some file with scaling factors of nodes

Example:
  ./unscale.pl -i table.atlas.oct -t nodepowers.tab

TEXT
    exit(0);
  }
  if (!(defined($parameter{'INPUT'}))) { die ("You need to give an input file\n"); }
  if (!(defined($parameter{'SCALINGTABLE'}))) { die ("You need to give a scaling table\n"); }
}

