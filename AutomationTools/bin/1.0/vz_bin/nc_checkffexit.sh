#! /bin/sh

#----------------------------------------#
# verify if the firefox is normal to exit;
#----------------------------------------#

echo "Verify if the firefox process has been removed....."

for i in 1 2 3 4 5
do
    echo "ps aux |grep firefox"	
    ps aux | grep firefox | grep -v grep
    if [ $? == 0 ]; then
	
	echo "The firefox doesnot exit, please wait 15 seconds again"
	sleep 15
    else
	echo "The firefox process has exited..."
  bash $SQAROOT/bin/1.0/common/resetffjssh.sh
	exit 0
    fi
done

echo "reset firefox process...."
bash $SQAROOT/bin/1.0/common/resetffjssh.sh
