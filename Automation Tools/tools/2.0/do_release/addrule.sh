#!/bin/bash
#
#
#
#


rcfile=/root/.bashrc
#rcfile=bashrc
echo "find automation rule in ${rcfile}"
grep -e "if.*automationrc" ${rcfile} | grep -vE "^#" 
rc=$?
#echo "rc = ${rc}"
if [ "$rc" == "0" ]; then
    echo "found"
else
    cp -i ./automationrc /root/.automationrc
    echo "not found,need to add this rule "
    # add rule in bashrc
    echo "" >> ${rcfile}
    echo "" >> ${rcfile}
    echo "" >> ${rcfile}


    echo '
#
# add automation rc file
#
if [ -f ~/.automationrc ]; then ##
    . ~/.automationrc
fi
' >> ${rcfile}

    source ${rcfile}
fi
