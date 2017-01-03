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
