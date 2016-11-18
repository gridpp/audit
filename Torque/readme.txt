Instructions
************

# Note: does not deal with multicore Torque setups. This is a requirement that I shall address shortly. sj, 18 Nov 2016
# Note: Today fixed above.... can't test fully (don't use torque mcore) sj, 18 Nov 2016

# Get a list of the files that cover the period you want, so the script below doesn't have to plough through them all.
# Since some records for Oct might lie in Aug or Sept, just, then list those too.

# Note: the location of the files may vary; check with your admin guy.

rm -f recordFilesCoveringPeriod
ls /var/lib/torque/server_priv/accounting/201609* >> recordFilesCoveringPeriod
ls /var/lib/torque/server_priv/accounting/201610* >> recordFilesCoveringPeriod
ls /var/lib/torque/server_priv/accounting/201611* >> recordFilesCoveringPeriod

# Get the UNIX epochs for the start and end of the period in question (in this case on the start of October or later, but before the 1st Nov)
startEpoch=`date --date="Oct 01 00:00:00 UTC 2016" +%s`
endEpoch=`date   --date="Nov 01 00:00:00 UTC 2016" +%s`

# Now run the script to get the job data for that period. You have to pass it the 
# Publishing Benchmark to which you scale. At Liverpool, we scale to 10 HS06, which is
# 2500 bogoSpecInt2K, hence we use 2500. Also give it the start and end.

./extractRecordsBetweenEpochs.pl recordFilesCoveringPeriod 2500 $startEpoch $endEpoch > table.oct

# Add up the tables to get the result for the month.

./accu.pl table.oct

# The work done for that month, in HS06 Hours, should pop out.

sj, 14 Nov 2016


