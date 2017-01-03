#!/bin/sh -x

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
