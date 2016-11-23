#!/usr/bin/perl -w
use strict;
use XML::Parser;
use Getopt::Long;

# Prototypes
sub getDurationInSeconds ($);
sub initParams();

# Global options
my %parameter;

#-------------------------------------

# Read the options
initParams();

# <WallDuration>PT2H24M41S</WallDuration>
# <CpuDuration urf:usageType="all">PT2H16M51S</CpuDuration>
# <ServiceLevel urf:type="Si2k" urf:description="">2500.0</ServiceLevel>


my $parser = new XML::Parser ( Handlers => {   # Creates our parser object
                             Start   => \&hdl_start,
                             End     => \&hdl_end,
                             Char    => \&hdl_char,
                             Default => \&hdl_def,
                           });
my $where = 'dontcare';
my $wallDuration = undef;
my $cpuDuration = undef;
my $globalUserName = undef;
my $host           = undef;
my $endTime = undef;
my $serviceLevel = undef;
my $processors = undef;

my $xml = '';
open (INPUT,"$parameter{INPUT}") or die("Cannot open $parameter{INPUT}\n");
while(<INPUT>) {
  $xml = $xml . $_;
}
close(INPUT);

$parser->parse($xml);

if ( (defined($wallDuration)) &&
     (defined($cpuDuration)) &&
     (defined($globalUserName)) &&
     (defined($host          )) &&
     (defined($endTime       )) &&
     (defined($processors)) &&
     (defined($serviceLevel)) ) {
  # 2500.0
  $serviceLevel =~ /([0-9\.]+)/;
  my $sl = $1;

  $processors    =~ /([0-9]+)/;
  my $procs = $1;

  my $wdHours = getDurationInSeconds($wallDuration) / 60 / 60;
  $wdHours = $wdHours * $procs;
  my $cpuHours = getDurationInSeconds($cpuDuration) / 60 / 60;

  my $wallHs = $wdHours * ($sl / 250);
  my $cpuHs = $cpuHours * ($sl / 250);
  #print("wallHs06Hours: $wallHs, cpuHs06Hours: $cpuHs, processors: $procs\n");
  #print("GlobalUserName: $globalUserName\n");

  # Now we check if (a) The EndTime field matches the month we want and 
  #                 (b) The GlobalUserName matches at least one of the partial DNs.
  # If so, we print out the details for that file
  # 2016-10-25T22:41:32Z
  $endTime =~ /(\d+)\-(\d+)\-/;
  my $endYearOfRecord     = $1;
  my $endMonthOfRecord = $2;
  if (($parameter{YEAR} == $endYearOfRecord) &&($parameter{MONTH} ==  $endMonthOfRecord)) {
    my $selected = 0;
    if ($#{$parameter{'DNBITS'}} <  0) {
      $selected = 1;
    }
    else {
      for my $pdn (@{$parameter{'DNBITS'}}) {
        if ($globalUserName =~ /$pdn/) {
          $selected = 1;
          last;
        }
      }
    }
    if ($selected) {
      print("wallHs06Hours: $wallHs, cpuHs06Hours: $cpuHs, processors: $procs, host: $host\n");
    }
  }
}
else {
  print("Did not find all the info\n");
}
  
 # The Handlers
sub hdl_start{
  my ($p, $elt, %atts) = @_;
  $atts{'_str'} = '';
  $where = 'dontcare';
  if ($elt eq 'WallDuration') {
    $where = 'WallDuration';
  }
  if ($elt eq 'CpuDuration') {
    if ($atts{'urf:usageType'} eq 'all') {
      $where = 'CpuDuration';
    }
  }
  if ($elt eq 'GlobalUserName') {
    $where = 'GlobalUserName';
  }
  if ($elt eq 'Host') {
    $where = 'Host';
  }
  if ($elt eq 'EndTime') {
    $where = 'EndTime';
  }
  if ($elt eq 'ServiceLevel') {
    if ($atts{'urf:type'} eq 'Si2k') {
      $where = 'ServiceLevel';
    }
  }
  if ($elt eq 'Processors') {
    $where = 'Processors';
  }
}
  
sub hdl_end{
  my ($p, $elt) = @_;
}
 
sub hdl_char {
  my ($p, $str) = @_;
  if ($where =~ /WallDuration/) {
    $wallDuration .= $str;
  }
  if ($where =~ /CpuDuration/) {
    $cpuDuration .= $str;
  }
  if ($where =~ /Host/) {
    $host .= $str;
  }
  if ($where =~ /EndTime/) {
    $endTime .= $str;
  }
  if ($where =~ /ServiceLevel/) { 
    $serviceLevel .= $str; 
  }
  if ($where =~ /Processors/) { 
    $processors .= $str; 
  }

}
 
sub hdl_def { }  # We just throw everything else

sub getDurationInSeconds ($) {
  my $pattern = shift();

  my $days  = 0; my $hours  = 0; my $mins  = 0; my $secs  = 0;
  $pattern =~ /P(\d+D)?T(\d+H)?(\d+M)?(\d+S)?/;

  if (defined($1)) {  $days = $1; chop($days)}
  if (defined($2)) {  $hours= $2; chop($hours)}
  if (defined($3)) {  $mins = $3; chop($mins)}
  if (defined($4)) {  $secs = $4; chop($secs)}
  my $duration = $secs + ($mins * 60) + ($hours * 60 * 60) + ($days * 24 * 60 * 60);
  return $duration;
}

#---------------------------------------------
# Read the command line options
#---------------------------------------------
sub initParams() {

  # Can accept a set of DNs (or parts of DNs)
  $parameter{'DNBITS'} = [];

  # Read the options
  GetOptions ('h|help'          =>   \$parameter{'HELP'},
              'i|inputfile:s'   =>   \$parameter{'INPUT'} ,
              'm|month:i'     =>   \$parameter{'MONTH'} ,
              'y|year:i'     =>   \$parameter{'YEAR'} ,
              'd|dn:s'        =>    $parameter{'DNBITS'} ,
              );

  if (defined($parameter{'HELP'})) {
    print <<TEXT;

Abstract: A tool to audit accounts

  -h  --help                       Prints this help page
  -d  --dn           ATLAS         Part of some DN (can add several acceptable ones)
  -y  --year         2016          Some year
  -m  --month        Oct           Some month, 1 to 12
  -i  --inputfile    file          A file to test and print

Example:
  ./testAndPrintARC.pl -y 2016 -m 10 -i x  -dn ATLAS -dn otherVO

TEXT
    exit(0);
  }
  if (!(defined($parameter{'MONTH'}))) { die ("You need to give a month, 1 to 12\n"); }
  if (!(defined($parameter{'YEAR'}))) { die ("You need to give a year, e.g. 2016\n"); }
  if (!(defined($parameter{'INPUT'}))) { die ("You need to give an input file\n"); }

}



