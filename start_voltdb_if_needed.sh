#!/bin/sh

# This file is part of VoltDB.
#  Copyright (C) 2008-2017 VoltDB Inc.
# 
#  Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
# 
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
# 
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
#  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#  OTHER DEALINGS IN THE SOFTWARE.



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
	if 
       		[ -r /voltdbdata/voltdbroot/licence.xml ]
	then
		nohup voltdb start  --dir=${MOUNTPOINT}  --host=${VDB_HOSTS} -l /voltdbdata/voltdbroot/licence.xml  2>&1 >>  $LOGFILE  & 
	else
		nohup voltdb start  --dir=${MOUNTPOINT}  --host=${VDB_HOSTS}  2>&1 >>  $LOGFILE  & 
	fi
 		
else	
	echo `date` Already running... | tee -a  $LOGFILE
fi

#
# See if iperf3 already running...
#
# See if VoltDB already running...
VRUN=`ps -deaf | grep iperf3 |  grep -v grep`

if 
	[ "$VRUN" = "" ]
then
	echo `date` Starting iperf3... | tee -a  $LOGFILE
	iperf3 -s -D	
else	
	echo `date` Already running... | tee -a  $LOGFILE
fi


exit 0
