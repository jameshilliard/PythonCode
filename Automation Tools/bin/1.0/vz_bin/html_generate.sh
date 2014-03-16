#/bin/bash
declare -i a
a=1
while [ $a -lt 100 ] ; do
   mkdir tst${a}
   rc=`cd tst${a};wget www.google.com;cd ..`
   a=$[a+1]
done
