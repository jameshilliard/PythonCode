declare -i pingResult=`cat $1 | grep "packet loss" | awk '{print $4}'`
echo "received packet "$pingResult
if [ $pingResult -gt 0 ]; then
echo "Ping WAN ISP ok";
exit 0;
else
echo "Ping WAN ISP failed";
exit 1;
fi


