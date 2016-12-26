#!/bin/sh

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


