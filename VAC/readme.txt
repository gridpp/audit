Instructions
************

# For global figures (not specific to any experiment) use these instuctions
#--------------------------------------------------------------------------

# Install the software on all the VAC nodes, off the root dir.

cd /root
git clone https://github.com/gridpp/audit.git

# Also install it on a control node, i.e. a node that you can use to access all the
# vac nodes with ssh but without a password. Perhaps use ssh-agent, ssh-add ...

cd audit/VAC/controlnode/

# Get the UNIX epochs for the start and end of the period in question
startEpoch=`date --date="Jan 01 00:00:00 UTC 2017" +%s`
endEpoch=`date   --date="Feb 01 00:00:00 UTC 2017" +%s`

# Get a list of all the vacnodes in a file called vacnodes, then:
for n in `cat vacnodes`; do ./simpleAudit.sh  $n /var/lib/vac/apel-archive  1483228800  1485907200; done > table.jan

# Now process the file to get the result.
./accu.pl table.jan

# The work done for that month, in HS06 Hours, should pop out.
# The job count for the month is represented by the number of lines in the table file.

# sj, 06 Feb 2017
