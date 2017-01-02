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

if
       [ $# != 8 ]
then
       echo Usage: sudo server.sh ip1 ip2 ip3 kfactor cmdlogging password demotype instancetype
       exit 1
fi
 
touch /home/ubuntu/PLEASE_WAIT.txt

KFACTOR=$4
CMDLOGGING=$5
PASSWD=$6
DEMOPARAM=$7
INSTANCETYPE=$8

XS="\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\n"
XE="\n\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
DEVICE=/dev/xvdf
MOUNTPOINT=/voltdbdata
LICFILE=${MOUNTPOINT}/voltdbroot/licence.xml

echo Update APT...
apt update

echo ${XS}  Parsams = $* ${XS} 

echo ${XS}  upgrade APT packages if needed...${XS} 
echo 'Y' | apt upgrade

echo ${XS} Make sure iperf3 is installed...${XS} 
echo 'Y' | apt install iperf3

if
        [ ! -d ${MOUNTPOINT} ]
then
        echo  ${XS} Creating ${MOUNTPOINT} mount point... ${XE}
        mkdir ${MOUNTPOINT}
fi

if
        [ "`file -s ${DEVICE}`" = "${DEVICE}: data" ]
then
        echo ${XS} Creating filesystem on ${DEVICE}... ç
        mkfs -t ext4  ${DEVICE}
fi

if
        [ "`df -k | grep xvdf`" = "" ]
then
        echo ${XS} Mounting ${DEVICE}... ${XE}
        mount ${DEVICE} ${MOUNTPOINT}
fi

if
        [ "`grep ${DEVICE} /etc/fstab`" = "" ]
then
        echo ${XS} Creating fstab entry for ${DEVICE}... ${XE}
        cp /etc/fstab /etc/fstab.`date '+%y%m%d_%H%M'`

        UUID=`sudo file -s ${DEVICE} | awk -F= '{ print $2}' | awk {'print $1}'`
        echo UUID=${UUID}...

        echo UUID=${UUID} $MOUNTPOINT   ext4    defaults,nofail        0       2 >> /etc/fstab
fi

if
        [ ! -r ${MOUNTPOINT}/voltdbroot ]
then
        echo ${XS} Creating ${MOUNTPOINT}/voltdbroot... ${XE}
        mkdir ${MOUNTPOINT}/voltdbroot
fi

if
        [ ! -r ${MOUNTPOINT}/voltdbroot/profile_voltdb ]
then
        echo ${XS} Creating ${MOUNTPOINT}/voltdbroot/profile_voltdb... ${XE}
        echo VDB_LEADER=$1 > ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo VDB_HOST2=$2 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo VDB_HOST3=$3 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo VDB_HOSTS=$1,$2,$3 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_LEADER >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_HOST2 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_HOST3 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_HOSTS >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        chmod 755 ${MOUNTPOINT}/voltdbroot/profile_voltdb
        
        if
              [ "`grep profile_voltdb /home/ubuntu/.bashrc`" = "" ]
        then
              echo ${XS} Adding call to  ${MOUNTPOINT}/voltdbroot/profile_voltdb to $HOME/.bashrc ... ${XE}
              echo \# >>   /home/ubuntu/.bashrc
              echo \# VoltDB specific stuff >>  /home/ubuntu/.bashrc
              echo \# >>   /home/ubuntu/.bashrc

              echo "if [ -f \"/voltdbdata/voltdbroot/profile_voltdb\" ]; then" >>   /home/ubuntu/.bashrc
              echo "  . /voltdbdata/voltdbroot/profile_voltdb" >>   /home/ubuntu/.bashrc
              echo "fi" >>   /home/ubuntu/.bashrc
        fi
fi

if  
       [ ! -r ${MOUNTPOINT}/voltdbroot/config.xml ]
then
       echo ${XS} Creating ${MOUNTPOINT}/voltdbroot/config.xml... ${XE}
       
       mkdir ${MOUNTPOINT}/voltdbroot
       chown ubuntu ${MOUNTPOINT}/voltdbroot
       
       PARAM_CMDLOGDIR=${MOUNTPOINT}/voltdbroot/cmdlog
       PARAM_CMDLOG_SNAPSHOT=${MOUNTPOINT}/voltdbroot/cmdlogsnapshot
       PARAM_SNAPSHOTS=${MOUNTPOINT}/voltdbroot/snapshots
       
       # Calculate sitesperhost
       SITESPERHOST=8
       
       if
              [ "$INSTANCETYPE" = "m4.4xlarge" ]
       then
              SITESPERHOST=8
       fi
       
       if
              [ "$INSTANCETYPE" = "m4.10xlarge" ]
       then
              SITESPERHOST=16
       fi
       
       if
              [ "$INSTANCETYPE" = "m4.16xlarge" ]
       then
              SITESPERHOST=16
       fi

       
       curl https://raw.githubusercontent.com/srmadscience/voltdb-cloudformation/master/configxml_template \
       | sed '1,$s/'PARAM_PASSWORD'/'${PASSWD}'/g' \
       | sed '1,$s/'PARAM_KFACTOR'/'${KFACTOR}'/g' \
       | sed '1,$s/'PARAM_CMDLOG_ENABLED'/'${CMDLOGGING}'/g' \
       | sed '1,$s/'PARAM_SYNC'/'false'/g' \
       | sed '1,$s_'PARAMCMDLOGDIR'_'${PARAM_CMDLOGDIR}'_g' \
       | sed '1,$s_'PARAMCMDLOGSNAPSHOT'_'${PARAM_CMDLOG_SNAPSHOT}'_g' \
       | sed '1,$s_'PARAMSNAPSHOTS'_'${PARAM_SNAPSHOTS}'_g' \
       | sed '1,$s/'PARAM_SITESPERHOST'/'${SITESPERHOST}'/g' \
       > ${MOUNTPOINT}/voltdbroot/config.xml
fi

for i in start_voltdb_if_needed.sh update_for_cluster.sh update_java_clients.sh update_example_hosts.sh
do
       if 
              [ ! -r /home/ubuntu/${i} ]
       then
              echo ${XS} Creating ${i}... ${XE}
              curl https://raw.githubusercontent.com/srmadscience/voltdb-cloudformation/master/${i}  > /home/ubuntu/${i}
              chown ubuntu  /home/ubuntu/${i}
              chmod u+rwx /home/ubuntu/${i}
       fi
done

echo ${XS} Calling voltdb init... ${XE}

# Avoid issues with params and su by echo-ing in...
echo voltdb init -D ${MOUNTPOINT}/voltdbroot --config=${MOUNTPOINT}/voltdbroot/config.xml | su - ubuntu

ls -alR ${MOUNTPOINT}/voltdbroot
cat  /voltdbdata/voltdbroot/log/volt.log 

crontab -u ubuntu -l > /dev/null
if 
       [ "$?" = "1" ]
then
       echo ${XS} Creating crontab... ${XE}
       curl https://raw.githubusercontent.com/srmadscience/voltdb-cloudformation/master/ubuntu.crontab  > /home/ubuntu/ubuntu.crontab
       crontab -u ubuntu /home/ubuntu/ubuntu.crontab 
       rm /home/ubuntu/ubuntu.crontab
       crontab -l
fi

echo ${XS} Updating demo files... ${XE}
sh /home/ubuntu/update_for_cluster.sh

echo ${XS} Done.. ${XE}

rm /home/ubuntu/PLEASE_WAIT.txt

