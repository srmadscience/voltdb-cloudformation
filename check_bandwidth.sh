#!/bin/sh -x

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

ITYPE=`ec2metadata --instance-type`
SECS=30
INT=10
TRANSIZE=1024
TARGET_IP=${VDB_LEADER}
MY_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

if

        [ "${MY_IP}" = "${TARGET_IP}" ]
then
        TARGET_IP=${VDB_HOST2}
fi



echo Instance Type = $ITYPE 
echo Spending $SECS seconds testing bandwidth

FNAME=check_bandwidth_${ITYPE}_`date '+%y%m%d_%H%M%S'.lst`
iperf3 -c ${TARGET_IP} -f K -t $SECS -i $INT | tee -a $FNAME

RECS=`cat $FNAME | awk '{ print $7}' | grep '^[0-9]' | tail -n 1`
RECS=`expr $RECS \* 1024`
RECS=`expr $RECS / $TRANSIZE `

echo Maximum plausible ${TRANSIZE} byte transactions supperted by this nerwork each second = $RECS | tee -a $FNAME
exit 0
