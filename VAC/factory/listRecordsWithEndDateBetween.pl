#!/usr/bin/perl
use strict;
use File::Find;

#-- Main --

if ($#ARGV < 2 ) {
  die ("Please give a dir, start and end epoch\n");
}

my $dir = shift();
my $start = shift();
my $end = shift();

find(\&wanted, $dir);

sub getEndTime($) {
  my $f = shift();
  open(THEFILE,$f) or die("No open $f");
  while(<THEFILE>) {
    my $line = $_;
    chomp($line);
    if ($line =~ /EndTime: (\d+)/) {
      close(THEFILE);
      return $1;
    }
  }
  close(THEFILE);
  return -1;
}

sub wanted {
  my $theFile = $File::Find::name;
  if ( -f $theFile) {
    my $endTime = getEndTime($theFile);
    if (($endTime >= $start) && ($endTime < $end)) {
      print("$theFile\n");
    }
  }
}

