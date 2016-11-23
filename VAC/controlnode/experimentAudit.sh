#!/bin/bash

if [ $# != 5 ]; then
  echo Please give node to audit, dir, startEpoch and endEpoch, exp
  exit
fi
node=$1
dir=$2
startEpoch=$3
endEpoch=$4
exp=$5

ssh -o ConnectTimeout=3 $node ./audit/VAC/factory/testAndPrintVAC.pl -dir $dir -se $startEpoch -ee $endEpoch -fqan=$exp

