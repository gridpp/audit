#!/usr/bin/perl -w
use strict;
use XML::Parser;
sub getDurationInSeconds ($);

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
my $serviceLevel = undef;
my $processors = undef;

my $xml = '';
while(<>) {
  $xml = $xml . $_;
}
$parser->parse($xml);

if ( (defined($wallDuration)) &&
     (defined($cpuDuration)) &&
     (defined($globalUserName)) &&
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
  print("GlobalUserName: $globalUserName\n");
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
  if ($where =~ /GlobalUserName/) {
    $globalUserName .= $str;
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


