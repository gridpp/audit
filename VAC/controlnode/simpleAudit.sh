#!/bin/bash

if [ $# != 4 ]; then
  echo Please give node to audit, dir, startEpoch and endEpoch
  exit
fi
node=$1
dir=$2
startEpoch=$3
endEpoch=$4

ssh -o ConnectTimeout=3 $node ./audit/VAC/factory/testAndPrintVAC.pl -dir $dir -se $startEpoch -ee $endEpoch


