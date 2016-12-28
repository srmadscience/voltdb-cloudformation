#!/bin/sh

. /home/ubuntu/.profile
. /voltdbdata/voltdbroot/profile_voltdb

MOUNTPOINT=/voltdbdata
LOGFILE=/voltdbdata/voltdbroot/log/start_voltdb_if_needed`date '+%y%m%d'`.log
STOPFILE=/home/ubuntu/stopvoltdb.txt 

# See if VoltDB already running...
VRUN=`ps -deaf | grep org.voltdb.VoltDB | grep java | grep -v grep`

if 
	[ -r "$STOPFILE" ]
then
	echo `date` Stop file ${STOPFILE} present - not starting VoltDB... | tee -a  $LOGFILE
	exit 1

fi

if 
	[ "$VRUN" = "" ]
then
	echo `date` Starting VoltDB... | tee -a  $LOGFILE
 	nohup voltdb start  --dir=${MOUNTPOINT}  --host=${VDB_HOSTS}  2>&1 >>  $LOGFILE  & 	
else	
	echo `date` Already running... | tee -a  $LOGFILE
fi

exit 0
