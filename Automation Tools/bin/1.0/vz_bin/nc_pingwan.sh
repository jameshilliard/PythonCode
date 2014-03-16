#! /bin/sh 

#----------------------------------------#
# verify the timeout of reset the channel;
#----------------------------------------#

function f_negative 
{
for i in 1 2 3 4 5 6 7 8 9 10
do
    ping $wanpc -c 3
    if [ "$?" != "0" ]; then
      echo "Can't reach wan pc,  wait and try again after sleep 5 sec...."
	    sleep 5
    else
	    echo "Error: Wan pc is reachabled"
	    exit 1
    fi
done
echo "Successful: cannot ping to wan pc"
exit 0
}

function f_positive
{
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
do
    ping $wanpc -c 3
    if [ "$?" != "0" ]; then
	    echo "Can't reach wan pc,  wait and try again after sleep 15 sec...."
	    sleep 15
    else
	    echo "Successful: Wan pc is reachabled"
	    exit 0
    fi
done
echo "Error cannot ping to wan pc"
exit 1
}

wanpc=$1
gwip=$2
subnet=$3
is_negative=$4

route delete -net $subnet gw $gwip 2>/dev/null
route add -net $subnet gw $gwip

echo "Verify if WAN PC is reachabled..."

case "$is_negative"
in
	-n) f_negative;;
  * ) f_positive;;

esac
