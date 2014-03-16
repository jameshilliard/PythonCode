echo "Change $1 route table"
perl $U_PATH_TBIN/sshcli.pl -l $6 -o $6/routetable.log -d $1 -u $2 -p $3 -v "route del default && route add default gw $4 dev $5" >  $6/result.log

result=`cat $6/result.log | grep SIOC | awk '{print $1}' | sed 's/://'`

echo $result

if [ $result == "SIOCDELRT" ]; then

echo "add default route again"

perl $U_PATH_TBIN/sshcli.pl -l $6 -o $6/routetable.log -d $1 -u $2 -p $3 -v "route add default gw $4 dev $5" >  $6/result.log


result=`cat $6/result.log | grep SIOC`

echo $result

fi

if [ -z $result ]; then
echo modify route table ok
exit 0
else 
echo modify route table ng
exit 1
fi




