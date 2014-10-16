echo "Begin $2 iperf test "
if [ $1 == "local" ]; then
	if [ $2 == "udp" ]; then
		iperf -s -p $3 -u  > iperftest.log &
		perl $U_PATH_TBIN/sshcli.pl -l $8 -o $8/iperf.log -d $4 -u $5 -p $6 -v "iperf -c $7 -p $3 -u"
	else
		iperf -s -p $3 > iperftest.log &
		echo "start iperf client"
		perl $U_PATH_TBIN/sshcli.pl -l $8 -o $8/iperf.log -d $4 -u $5 -p $6 -v "iperf -c $7 -p $3 "
	fi

	killall iperf

else
	logfile=$G_CURRENTLOG/iperftest_svr.log
	echo "log path : $logfile"
	if [ $2 == "udp" ]; then
		perl $U_PATH_TBIN/sshcli.pl -l $8 -o $8/iperf.log -d $4 -u $5 -p $6 -v "echo 'iperf -s -p $3 -u > $logfile &' > iperf_server.sh; chmod 777 ./iperf_server.sh ;./iperf_server.sh"
		if [ $? -ne 0 ]; then
			exit -1
		fi
		iperf -c $7 -p $3 -u  &
	else
		perl $U_PATH_TBIN/sshcli.pl -l $8 -o $8/iperf.log -d $4 -u $5 -p $6 -v "echo 'iperf -s -p $3 > $logfile &' > iperf_server.sh; chmod 777 ./iperf_server.sh ; ./iperf_server.sh"
		if [ $? -ne 0 ]; then
			exit -1
		fi
		iperf -c $7 -p $3 &
	fi

	echo "60 seconds timed out"
	sleep 60
	perl $U_PATH_TBIN/sshcli.pl -l $8 -o $8/iperf.log -d $4 -u $5 -p $6 -v "killall iperf; rm -f ./iperf_server.sh ; cat $logfile" > iperftest.log
	killall iperf
fi

echo "read result"
bandwith=`cat ./iperftest.log |  grep "bits/sec" | awk '{print $7}'`
bandwith_unit=`cat ./iperftest.log |  grep "bits/sec" | awk '{print $8}'`
echo "The bandwith of iperf test is : $bandwith $bandwith_unit" 


if [ -n "$bandwith" -a "$bandwith" != "0" ]; then
	echo $9

	if [ "$9" == "unblocked" ]; then
		echo "iperf unblocked test ok";
		exit 0;
	else
		echo "iperf blocked test ng";
		exit 1;
	fi
else

	if [ "$9" == "unblocked" ]; then
		echo "iperf unblocked test ng";
		exit 1;
	else
		echo "iperf blocked test ok";
		exit 0;
	fi
fi

exit 0
