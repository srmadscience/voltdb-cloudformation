#!/bin/sh

. $HOME/.profile

SEDFILE=/tmp/$$.sed
FNAME=$1
TEMPFILE=/tmp/$$.tmp

echo 1,\$s_STARTUPLEADERHOST=\"localhost\"_STARTUPLEADERHOST=${VDB_LEADER}_g > ${SEDFILE}
echo 1,\$s_SERVERS=\"localhost\"_SERVERS=${VDB_HOSTS}_g >> ${SEDFILE}

cat $FNAME  | sed -f ${SEDFILE}  > ${TEMPFILE}
mv ${TEMPFILE} ${FNAME}
chmod 755 ${FNAME}
