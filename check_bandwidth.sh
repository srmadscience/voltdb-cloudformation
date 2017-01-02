#!/bin/sh

ITYPE=`ec2metadata --instance-type`
SECS=30
INT=1
TRANSIZE=256

echo Instance Type = $ITYPE 
echo Spending $SECS seconds testing bandwidth

FNAME=check_bandwidth_${ITYPE}_`date '+%y%m%d_%H%M%S'.lst`
iperf3 -c 54.82.218.143 -f K -t $SECS -i $INT | tee -a $FNAME
RECS=`cat $FNAME | awk '{ print $7}' | grep '^[0-9]' | tail -n 1`
RECS=`expr $RECS \* 1024`
RECS=`expr $RECS / $TRANSIZE `

echo Maximum possible ${TRANSIZE} byte transactions supperted by this nerwork each second = $RECS
