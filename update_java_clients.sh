#!/bin/sh
. $HOME/.profile

SEDFILE=/tmp/$$.sed
FNAME=$1

if
        [ ! -r "$FNAME" ]
then
        echo Usage: $0 filename
        exit 1

fi

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

TEMPFILE=/tmp/$$.java

echo 1,\$s_new ClientConfig\(\"\", \"\", new StatusListener\(\)\)_new ClientConfig\(\"$DBUSER\", \"$DBPASS\", new StatusListener\(\)\)_g > ${SEDFILE}


sed -f ${SEDFILE}  > ${TEMPFILE} < $FNAME
mv ${TEMPFILE} ${FNAME}
rm ${SEDFILE}
