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
       echo Usage: sudo server.sh ip1 ip2 ip3 kfactor cmdlogging password demotype
       exit 1
fi
 
KFACTOR=$4
CMDLOGGING=$5
PASSWD=$6
DEMOPARAM=$7

XS="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n\n"
XE="\n\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
DEVICE=/dev/xvdf
MOUNTPOINT=/voltdbdata

echo Update APT...
apt update

echo upgrade APT packages if needed...
echo 'Y' | apt upgrade

if
        [ ! -d ${MOUNTPOINT} ]
then
        echo Creating ${XS} {MOUNTPOINT} mount point... ${XE}
        mkdir ${MOUNTPOINT}
fi

if
        [ "`file -s ${DEVICE}`" = "${DEVICE}: data" ]
then
        echo ${XS} Creating filesystem on ${DEVICE}... ${XE}
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
        echo VDB_HOSTS=$1,$2,$3 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_LEADER >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo export VDB_HOSTS >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        chmod 755 ${MOUNTPOINT}/voltdbroot/profile_voltdb
        
        if
              [ "`grep profile_voltdb $HOME/.bashrc`" = "" ]
        then
              echo ${XS} Adding call to  ${MOUNTPOINT}/voltdbroot/profile_voltdb to $HOME/.bashrc ... ${XE}
              echo \# >>  $HOME/.bashrc
              echo \# VoltDB specific stuff >>  $HOME/.bashrc
              echo \# >>  $HOME/.bashrc

              echo "if [ -f \"/voltdbdata/voltdbroot/profile_voltdb\" ]; then" >>  $HOME/.bashrc
              echo "  . /voltdbdata/voltdbroot/profile_voltdb" >>  $HOME/.bashrc
              echo "fi" >>  $HOME/.bashrc
        fi
fi

if  
       [ ! -r ${MOUNTPOINT}/voltdbroot/config.xml ]
then
       echo ${XS} Creating ${MOUNTPOINT}/voltdbroot/config.xml... ${XE}
       curl https://raw.githubusercontent.com/srmadscience/voltdb-cloudformation/master/configxml_template | sed '1,$s/'PARAM_KFACTOR'/'${KFACTOR}'/g' > ${MOUNTPOINT}/voltdbroot/config.xml
fi



