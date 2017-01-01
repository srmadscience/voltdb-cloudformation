#!/bin/sh
. $HOME/.profile

SEDFILE=/tmp/$$.sed
TEMPFILE=/tmp/$$.tmp
FNAME=$1

if
        [ ! -r "$FNAME" ]
then
        echo Usage: $0 filename
        exit 1

fi
FDIRNAME=`dirname $FNAME`
FBASENAME=`basename $FNAME`
FNEWNAME=runCluster.sh

#
# find username, password
#

CFGXML=/voltdbdata/voltdbroot/config.xml

if
        [ ! -r "${CFGXML}" ]
then
        echo Unable to find $CFGXML
        exit 2

fi

UNAME_LINE=`grep password /voltdbdata/voltdbroot/config.xml`
DBUSER=`echo $UNAME_LINE | awk -F\" '{ print $2}'`
DBPASS=`echo $UNAME_LINE | awk -F\" '{ print $6}'`

echo 1,\$s_STARTUPLEADERHOST=\"localhost\"_STARTUPLEADERHOST=${VDB_LEADER}_g > ${SEDFILE}
echo 1,\$s_SERVERS=\"localhost\"_SERVERS=${VDB_HOSTS}_g >> ${SEDFILE}
echo 1,\$s_sqlcmd _sqlcmd --user=${DBUSER} --password=${DBPASS} _g >> ${SEDFILE}

sed -f ${SEDFILE}  > ${FDIRNAME}/${FNEWNAME} < ${FNAME}
chmod 755 ${FDIRNAME}/${FNEWNAME}
rm ${SEDFILE}


cd ${FDIRNAME}
./${FNEWNAME} jars
