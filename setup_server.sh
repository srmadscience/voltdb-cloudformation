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
 
DEVICE=/dev/xvdf
MOUNTPOINT=/voltdbdata

echo Update APT...
apt update

echo upgrade APT packages if needed...
echo 'Y' | apt upgrade

if
        [ ! -d ${MOUNTPOINT} ]
then
        echo Creating ${MOUNTPOINT} moubt point...
        mkdir ${MOUNTPOINT}
fi

if
        [ "`file -s ${DEVICE}`" = "${DEVICE}: data" ]
then
        echo Creating filesystem on ${DEVICE}...
        mkfs -t ext4  ${DEVICE}
fi

if
        [ "`df -k | grep xvdf`" = "" ]
then
        echo Mounting ${DEVICE}...
        mount ${DEVICE} ${MOUNTPOINT}
fi

if
        [ "`grep ${DEVICE} /etc/fstab`" = "" ]
then
        echo Creating fstab entry for ${DEVICE}...
        cp /etc/fstab /etc/fstab.`date '+%y%m%d_%H%M'`

        UUID=`sudo file -s ${DEVICE} | awk -F= '{ print $2}' | awk {'print $1}'`
        echo UUID=${UUID}...

        echo UUID=${UUID} $MOUNTPOINT   ext4    defaults,nofail        0       2 >> /etc/fstab
fi

if
        [ ! -r ${MOUNTPOINT}/voltdbroot ]
then
        echo Creating ${MOUNTPOINT}/voltdbroot...
        mkdir ${MOUNTPOINT}/voltdbroot
fi

if
        [ ! -r ${MOUNTPOINT}/voltdbroot/profile_voltdb ]
then
        echo Creating ${MOUNTPOINT}/voltdbroot/profile_voltdb...
        echo VDB_LEADER=$1 > ${MOUNTPOINT}/voltdbroot/profile_voltdb
        echo VDB_HOSTS=$1,$2,$3 >> ${MOUNTPOINT}/voltdbroot/profile_voltdb
        chmod 755 ${MOUNTPOINT}/voltdbroot/profile_voltdb
fi


