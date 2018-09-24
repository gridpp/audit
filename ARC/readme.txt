Instructions
************

# For global figures (not specific to any experiment) use these instuctions
#--------------------------------------------------------------------------

# Archiving must be turned on in /etc/arc/conf. Check 
#   https://www.gridpp.ac.uk/wiki/Example_Build_of_an_ARC/Condor_Cluster

# Make a list of all the usage reports (location varies, check /etc/arc.conf)
ls /var/urs > /tmp/urs

# Get the ones for jobs that started in (say) sept
for f in `cat /tmp/urs`; do grep -l "EndTime.2016-09" /var/urs/$f; done > /tmp/urs.sept

# Parse them to make the table
for t in `cat /tmp/urs.sept `; do  ./parseUrs.pl $t; done > table.sept

# Sum up the table
cat table.sept | ~/accu.pl

# The usage for the month should pop out
# The job count for the monthis represendted by the number of lines in the table file.


# For figures specific to an experiment use these instuctions
#------------------------------------------------------------

TBD

sj, 21 Nov 2016
