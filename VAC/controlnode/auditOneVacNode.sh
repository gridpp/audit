#!/bin/bash

if [ $# != 4 ]; then
  echo Please give node to audit, dir, startEpoch and endEpoch
  exit
fi
node=$1
dir=$2
startEpoch=$3
endEpoch=$4

ssh -o ConnectTimeout=3 $node "./audit/VAC/factory/listRecordsWithEndDateBetween.pl $dir $startEpoch $endEpoch > ./audit/VAC/factory/recordList.txt"
ssh -o ConnectTimeout=3 $node "for f in \`cat ./audit/VAC/factory/recordList.txt\`; do cat \$f; done" | ./vacFileParse.pl

#startEpoch=`date --date="Oct 01 00:00:00 UTC 2016" +%s`
#endEpoch=`date --date="Nov 01 00:00:00 UTC 2016" +%s`
