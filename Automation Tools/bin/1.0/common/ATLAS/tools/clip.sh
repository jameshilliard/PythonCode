#!/bin/sh
##################################################################
#  Locate the script under testsuite dir
#  e.g. nc
#  cp clip.sh $SQAROOT/platform/1.0/verizon/testcases/nc/tcases/
#  cd $SQAROOT/platform/1.0/verizon/testcases/nc/tcases/
#  clip.sh -f nc.tst
#  then, go to /tmp dir to fetch the file.
#
##################################################################
if [ $1 != "-f" ]; then
    echo "usage: -f generated file\n"
    exit
fi
filename=$2
rm -f /tmp/$filename 2>/dev/null
for i in `ls`
do
    str=`cat $i | grep emaildesc`
    if [ "$str" != "" ]; then
        echo -n "$i" >> /tmp/$filename
        echo "$str" >> /tmp/$filename
    fi
done

echo "get the file under /tmp"
