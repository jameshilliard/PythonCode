#!/bin/bash

# Author        :   
# Description   :
#   This tool is using 
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#31 Oct 2011    |   1.0.0   |           | Inital Version
#23 Nov 2011    |   1.0.1   | andy      | sort special_node() list

VER="1.0.0"
echo "$0 version : ${VER}"

usage="bash $0 -e/ex <source file> -f <destination file> -out <log file name> -l <log dir> -node <node> [-n]"

USAGE()
{
    cat <<usge
USAGE : 
    
    bash $0 -e <source file> -f <destination file> -out <log file name> -l <log dir> -node <node>  

OPTIONS:

    -e:     source file,contains the expect values,no regex allowed
    -ex:    source exp file,contains the expect values,regex supported,but NO SPACE ALLOWED!!
    -f:     the file that to be conpaired with,usually is the GPV log file
    -out:   log file name,just the file name!
    -l:     log file path,just the path!
    -node:  the Node to be check
    -n:     negative mode

NOTES :  
    
    1.if you DON'T run this script in testcase , please put [-test] option in front of all the other options
    2.the [-l] and [-out] parameter can be omitted,in that case,the log will be in \$G_CURRENTLOG
    3.the [-e] and [-ex] and [-f] will defaultly considered in \$G_CURRENTLOG,if you want to use file in other path,please let me know
    4.it's ok if you use the [-e] [-ex] and [-node] parameter together.

EXAMPLES:   
    
    bash $0 -test -e <source file> -f <destination file> -out <log file name> -l <log dir> -node <node> [-n] 
usge
}

createlogname(){
    lognamex=$1
    cecho debug "ls $logpath/$lognamex*"
    ls $logpath/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        cecho debug "file not exists"
        cecho debug "so the current file to be created is : "$lognamex""_"1"
        currlogfilename=$lognamex"_""1"
    else
        cecho debug "file exists"
        curr=`ls $logpath/$lognamex*|wc -l`
        let "next=$curr+1"
        cecho debug "so the current file to be created is : "$lognamex"_"$next
        currlogfilename=$lognamex"_"$next
    fi
}


special_node=(
    $U_TR069_WANDEVICE_INDEX.WANConnectionNumberOfEntries
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Status 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.LinkEncapsulationSupported 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.LinkEncapsulationUsed 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.LineEncoding  
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UPBOKLE 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.LinkEncapsulationRequested 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.Status 
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DataPath
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.StandardsSupported
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.StandardUsed
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TestParams.
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.LineNumber
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ATURVendor
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ATURCountry
    #function need to be fixed
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate
    #function below won't work cause nodes not exist
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ACTINP
    #function need to be added
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.AllowedProfiles
    $U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile
    $U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.
    $U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.DuplexMode
    $U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.MaxBitRate
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.WANAccessType
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.PhysicalLinkStatus
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.EnabledForInternet
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent
    $U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived
    $U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANDSLLinkConfig.
    $U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANIPConnectionNumberOfEntries
    $U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANPPPConnectionNumberOfEntries
    $U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANEthernetLinkConfig.EthernetLinkStatus
    $U_TR069_DEFAULT_CONNECTION_SERVICE.
    $U_TR069_DEFAULT_CONNECTION_SERVICE.Stats.
    $U_TR069_DEFAULT_CONNECTION_SERVICE.Reset
    $U_TR069_DEFAULT_CONNECTION_SERVICE.PossibleConnectionTypes
    $U_TR069_DEFAULT_CONNECTION_SERVICE.ConnectionStatus
    $U_TR069_DEFAULT_CONNECTION_SERVICE.ConnectionType
    $U_TR069_DEFAULT_CONNECTION_SERVICE.LastConnectionError
    $U_TR069_DEFAULT_CONNECTION_SERVICE.IdleDisconnectTime
    $U_TR069_DEFAULT_CONNECTION_SERVICE.AutoDisconnectTime
    $U_TR069_DEFAULT_CONNECTION_SERVICE.RSIPAvailable
    $U_TR069_DEFAULT_CONNECTION_SERVICE.NATEnabled 
    #CEPInfo
    InternetGatewayDevice.DeviceSummary
    #DevInfo
    InternetGatewayDevice.DeviceInfo.Manufacturer
    InternetGatewayDevice.DeviceInfo.ManufacturerOUI
    InternetGatewayDevice.DeviceInfo.ProductClass
    InternetGatewayDevice.DeviceInfo.FirstUseDate
    InternetGatewayDevice.DeviceInfo.ProcessStatus.CPUUsage
    InternetGatewayDevice.DeviceInfo.ProcessStatus.ProcessNumberOfEntries
    InternetGatewayDevice.DeviceInfo.MemoryStatus.Total
    InternetGatewayDevice.DeviceInfo.MemoryStatus.Free
    #WALNConfiguration
    InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_${U_TR069_CUSTOM_MANUFACTUREROUI}_KeyPassphrase
)

given_value_node=(
    #nodes below have a given value
    "InternetGatewayDevice.WANDevice.x.WANConnectionNumberOfEntries=1"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.AllowedProfiles=8a,8b,8c,8d,12a,12b,17a,30a"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.ATURVendor=00000000"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.ATURCountry=0000"   
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.Status=Up"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.LinkEncapsulationSupported=G.992.3_Annex_K_ATM"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.LineEncoding=DMT"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UPBOKLE=0"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.LinkEncapsulationRequested=G.992.3_Annex_K_ATM"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DataPath=None"
    "InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.LineNumber=1"
    "InternetGatewayDevice.WANDevice.x.WANEthernetInterfaceConfig.MaxBitRate=100Mbps"
    "InternetGatewayDevice.WANDevice.x.WANEthernetInterfaceConfig.DuplexMode=Half Duplex"
    "InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.EnabledForInternet=true"
    "InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.PhysicalLinkStatus=Up"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANDSLLinkConfig.ATMQoS=UBR"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANEthernetLinkConfig.EthernetLinkStatus=Up"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.ConnectionStatus=Connected"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.ConnectionType=IP_Routed"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.IdleDisconnectTime=[0-9][0-9]*"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.AutoDisconnectTime=[0-9][0-9]*"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.RSIPAvailable=false"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.NATEnabled=true"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.Reset=false"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.ConnectionStatus=Connected"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.ConnectionType=IP_Routed"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.IdleDisconnectTime=[0-9][0-9]*"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.AutoDisconnectTime=[0-9][0-9]*"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.RSIPAvailable=false"
    "InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.NATEnabled=true"
    "InternetGatewayDevice.DeviceInfo.Manufacturer=$U_TR069_CUSTOM_MANUFACTURER"
    "InternetGatewayDevice.DeviceInfo.ManufacturerOUI=$U_TR069_CUSTOM_MANUFACTUREROUI"
    "InternetGatewayDevice.DeviceInfo.ProductClass=$U_TR069_CUSTOM_PRODUCTCLASS"
    "InternetGatewayDevice.DeviceInfo.FirstUseDate=[0-9a-fA-F]*"
    "InternetGatewayDevice.DeviceInfo.ProcessStatus.CPUUsage=[0-9][0-9]*"
    "InternetGatewayDevice.DeviceInfo.ProcessStatus.ProcessNumberOfEntries=[0-9][0-9]*" 
    "InternetGatewayDevice.LANDevice.x.WLANConfiguration.x.X_${U_TR069_CUSTOM_MANUFACTUREROUI}_KeyPassphrase=  "
)
# $U_TR069_WANDEVICE_INDEX=InternetGatewayDevice.WANDevice.3
nodetype=common

##wanConnType=`echo $U_TR069_WANDEVICE_INDEX|awk -F. '{print }'`

switch(){
    cecho debug "entering switch"
    for ((i=0;i<${#special_node[@]};i++)); do
        if [ ${special_node[i]} == $node2ser  ]; then
            nodetype=$node2ser
        fi
    done
        
    cecho debug "nodetype="$nodetype

    if [ $nodetype == "common" ]; then
        cecho debug "entering switch : common"
        common
        let "result=$result+$?"
        cecho debug "the result now is : $result"
    else
        cecho debug "entering switch : special"
        special
        let "result=$result+$?"
        cecho debug "the result now is : $result"
    fi
}

cecho() {
    case $1 in
        debug)
            echo -e " $2 "
            ;;
        error)
            echo -e " $2 "
            ;;
        none)
            echo -e "$2"
            ;;
    esac
}

in_range(){
    # in_range $target_cli $targe_mtv $offset
    target=$1
    range_base=$2
    range_offset=$3
    cecho debug "range base : $range_base"
    cecho debug "range target : $target"
    cecho debug "range offset : $range_offset"
    range_bottom=`expr $range_base - $range_offset`
    range_top=`expr $range_base + $range_offset`
    real_offset=`expr $target - $range_base`

    cecho debug "range_bottom $range_bottom"
    cecho debug "range_top $range_top"

    if [ "$target" -ge "$range_bottom" -a "$target" -le "$range_top" ] ;then
        cecho debug "the number is just in the range"
        cecho debug "the real offset is :        $real_offset"
    elif [ "$target" -lt "$range_bottom" ] ;then
        cecho debug "the number is too small , it is not in the range"
        cecho debug "the real offset is :        $real_offset"
        echo "$node2ser" >> $logpath/$currlogfilename
        let "result=$result+1"
    elif [ "$target" -gt "$range_top" ] ;then
        cecho debug "the number is too big   , it is not in the range"
        cecho debug "the real offset is :        $real_offset"
        echo "$node2ser" >> $logpath/$currlogfilename
        let "result=$result+1"
    fi
}

detailedLog(){
    cecho debug "entering function detailedLog..."
    if [ "$node2ser" != "" ] ;then
        if [ -f $logpath/$currlogfilename ] ;then
            for j in `cat $logpath/$currlogfilename`
            do
                nodename=`echo $j`
                cecho debug "node name is $nodename"
                perl $U_PATH_TBIN/searchoperation.pl '-e' $nodename -f $logpath/$dst
                if [ $? -eq 0 ] ;then
                    echo "differ form expect value ->"`grep -o "$j.*" $logpath/$dst`>> $logpath/$currlogfilename".detail"
                else
                    echo "really not existed node ->"$j >> $logpath/$currlogfilename".detail"
                fi
            done
        else
            if [ $result -eq 0 ] ;then
                echo "passed node ->"$node2ser >> $logpath/$currlogfilename".detail"
                echo "passed node value ->"`grep "$node2ser" $logpath/$dst`>> $logpath/$currlogfilename".detail"
            else
                echo "failed node ->"$node2ser >> $logpath/$currlogfilename".detail"
                echo "failed node value ->"`grep "$node2ser" $logpath/$dst`>> $logpath/$currlogfilename".detail"
            fi
            
        fi
    fi
}

special(){

    givenValue(){
        cecho debug "the node is : $node2ser"
        
        value=$1
        cecho debug "the given value is $value"
	    cecho debug "currrent log is $G_CURRENTLOG"

        perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*$value" -f $logpath/$dst
    }

    InternetGatewayDevice.DeviceSummary(){
        deviceSummaryLog=`grep "$node2ser" $logpath/$dst`
        rc=$?
        if [ "$rc" -ne 0 ] ;then
            let "result=$result+1"
            echo "node2ser" >> $logpath/$currlogfilename
        else
            deviceSummaryValue=`echo "$deviceSummaryLog" | awk -F '=' '{print $2}' | sed 's/^ *//g'`
            echo "the value of $node2ser is $deviceSummaryValue"
            if [ -z "$deviceSummaryValue" ] ;then
                let "result=$result+1"
                echo "node2ser" >> $logpath/$currlogfilename
            fi
        fi
    }


    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnectionNumberOfEntries(){
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*1" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser" |awk '{print $1}'>> $logpath/$currlogfilename
        fi
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANPPPConnectionNumberOfEntries
\s*=\s*0" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANPPPConnectionNumberOfEntrie" >> $logpath/$currlogfilename
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnectionNumberOfEntries(){
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*1" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser" |awk '{print $1}'>> $logpath/$currlogfilename
        fi
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANIPConnectionNumberOfEntries
\s*=\s*0" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$U_TR069_WANDEVICE_INDEX.$U_TR069_WANCONNECTIONDEVICE_INDEX.WANIPConnectionNumberOfEntrie" >> $logpath/$currlogfilename
        fi
    }


    InternetGatewayDevice.WANDevice.x.WANEthernetInterfaceConfig.(){
        values=(
	       "Enable*=*true"
	       "Status*=*Enabled"
	       "MAC Address*=*$U_TR069_PTM0_MACADDRESS"
	       "MaxBitRate*=*"
	       "DuplexMode*=*actual duplexmode"       
		 )

        for ((i=0;i<${#values[@]};i++)); 
        do
            #grep "$node2ser${values[i]}" $logpath/$dst
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${values[i]}" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${values[i]}" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        done
    }

	InternetGatewayDevice.WANDevice.x.WANEthernetInterfaceConfig.Stats.(){
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesSent=$BytesSent"                          >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesReceived=$BytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsSent=$PacketsSent"                      >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsReceived=$PacketsReceived"              >> $output

	 	cecho debug "connection type : WAN EthernetInterfaceConfig"

        BytesSent_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesSent" |
                        awk -F= '{print $2}'`
	    BytesReceived_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.BytesReceived" |
                            awk -F= '{print $2}'`
        PacketsSent_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsSent" |
                            awk -F= '{print $2}'`
        PacketsReceived_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.PacketsReceived" |
                                awk -F= '{print $2}'`

	  	BytesSent_mtv=`grep "BytesSent" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
	  	BytesReceived_mtv=`grep "BytesReceived" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        PacketsSent_mtv=`grep "PacketsSent" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        PacketsReceived_mtv=`grep "PacketsReceived" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`	    

	    cecho debug "BytesSent_cli :$BytesSent_cli"
        cecho debug "BytesSent_mtv :$BytesSent_mtv"

 		cecho debug "BytesReceived_cli :$BytesReceived_cli"
        cecho debug "BytesReceived_mtv :$BytesReceived_mtv"

		cecho debug "PacketsSent_cli :$PacketsSent_cli"
        cecho debug "PacketsSent_mtv :$PacketsSent_mtv"

		cecho debug "PacketsReceived_cli:$PacketsReceived_cli"
        cecho debug "PacketsReceived_mtv:$PacketsReceived_mtv"

		if [ "$BytesSent_cli" != "$BytesSent_mtv" ] ;then
			in_range $BytesSent_cli $BytesSent_mtv $TotalBytesSent_range
        else 
            cecho debug "$BytesSent_cli"" matches ""$BytesSent_mtv"
        fi

		if [ "$BytesReceived_cli" != "$BytesReceived_mtv" ] ;then
        	in_range $BytesReceived_cli $BytesReceived_mtv $TotalBytesSent_range
        else 
        	cecho debug "$BytesReceived_cli"" matches ""$BytesReceived_mtv"
       	fi

		if [ "$PacketsSent_cli" != "$PacketsSent_mtv" ] ;then
            in_range $PacketsSent_cli $PacketsSent_mtv $TotalBytesSent_range
        else 
            cecho debug "$PacketsSent_cli"" matches ""$PacketsSent_mtv"
       	fi

		if [ "$PacketsReceived_cli" != "$PacketsReceived_mtv" ] ;then
            in_range $PacketsReceived_cli $PacketsReceived_mtv $TotalBytesSent_range
        else 
            cecho debug "$PacketsReceived_cli"" matches ""$PacketsReceived_mtv"
       	fi
    }


	InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.(){
        values=(
            "PPPoESessionID *= *[0-9][0-9]*"
            "DefaultGateway *= *$TMP_DUT_DEF_GW"
            "Username *= *$U_DUT_CUSTOM_PPP_USER"
            "Password  *= *$"
            "PPPEncryptionProtocol *= *"
            "PPPCompressionProtocol *= *"
            "PPPAuthenticationProtocol *= *AUTO_AUTH"
            "ExternalIPAddress *= *$TMP_DUT_WAN_IP"
            "PPPoESessionID *= *[0-9][0-9]*"
            "CurrentMRUSize *= *[0-9][0-9]*"
            "MaxMRUSize *= *0"
            "DNSEnabled *= *true"
            "DNSOverrideAllowed *= *false"
            "DNSServers *= *[a-zA-Z0-9][a-zA-Z0-9]*"
          #  "MACAddress *= *$U_TR069_PTM0_MACADDRESS"
            "MACAddressOverride *= *false"
            "TransportType *= *PPPoE"
            "PPPoEACName *= *[a-zA-Z0-9][a-zA-Z0-9]*"
            "PPPoEServiceName *= *[a-zA-Z0-9][a-zA-Z0-9]*"
            "RouteProtocolRx *= *Off"
            "PPPLCPEcho *= *[0-9][0-9]*"
            "PPPLCPEchoRetry *= *[0-9][0-9]*"
        )

        for ((i=0;i<${#values[@]};i++)); 
        do
            #grep "$node2ser${values[i]}" $logpath/$dst
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${values[i]}" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${values[i]}" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        done
        
        if [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.1" ] ;then
            cecho debug "connection type : ADSL"
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""MACAddress""\s*=\s*$U_TR069_ATM0_MACADDRESS" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser""MACAddress" |awk '{print $1}'>> $logpath/$currlogfilename
            fi

        elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.2" ] ;then
            cecho debug "connection type : VDSL"
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""MACAddress""\s*=\s*$U_TR069_PTM0_MACADDRESS" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser""MACAddress" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.3" ] ;then
            cecho debug "connection type : ETHERNET"
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""MACAddress""\s*=\s*$U_TR069_EWAN0_MACADDRESS" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser""MACAddress" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        fi

    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.(){
        values=(
            "AddressingType *= *DHCP"
            "ExternalIPAddress *= *$TMP_DUT_WAN_IP"
            "SubnetMask *= *$G_PROD_TMASK_BR0_0_0"
            "DefaultGateway *= *$TMP_DUT_DEF_GW"
            "DNSEnabled *= *true"
            "DNSOverrideAllowed *= *false"
            "DNSServers *= *[a-zA-Z0-9][a-zA-Z0-9]*"
            "MaxMTUSize *= *1500"
            "MACAddress *= *$U_TR069_PTM0_MACADDRESS"
            "MACAddressOverride *= *false"
        )

        for ((i=0;i<${#values[@]};i++)); 
        do
            #grep "$node2ser${values[i]}" $logpath/$dst
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${values[i]}" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${values[i]}" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        done
    }


    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.LastConnectionError(){
        possible_values=(
            ERROR_NONE
            ERROR_COMMAND_ABORTED
            ERROR_NOT_ENABLED_FOR_INTERNET
            ERROR_USER_DISCONNECT
            ERROR_ISP_DISCONNECT
            ERROR_IDLE_DISCONNECT
            ERROR_FORCED_DISCONNECT
            ERROR_NO_CARRIER
            ERROR_IP_CONFIGURATION
            ERROR_UNKNOWN
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardUsed : "$values
            echo "StandardUsed : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "1" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.LastConnectionError(){
        possible_values=(
            ERROR_NONE
            ERROR_COMMAND_ABORTED
            ERROR_NOT_ENABLED_FOR_INTERNET
            ERROR_USER_DISCONNECT
            ERROR_ISP_DISCONNECT
            ERROR_IDLE_DISCONNECT
            ERROR_FORCED_DISCONNECT
            ERROR_NO_CARRIER
            ERROR_IP_CONFIGURATION
            ERROR_UNKNOWN
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardUsed : "$values
            echo "StandardUsed : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "1" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.PossibleConnectionTypes(){
    #Expected Result 1:
    #1. Value of this parameter returned to ACS server is “Unconfigured” and  “IP_Routed”  (value check point).
        possible_values=(
            Unconfigured
            IP_Routed
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardUsed : "$values
            echo "StandardUsed : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "${#possible_values[@]}" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.PossibleConnectionTypes(){
    #Expected Result 1:
    #1. Value of this parameter returned to ACS server is '“Unconfigured” , “IP_Routed”, “IP_Bridged” ' (value check point).
        possible_values=(
            Unconfigured
            IP_Routed
            IP_Bridged
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardUsed : "$values
            echo "StandardUsed : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "${#possible_values[@]}" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANPPPConnection.x.Stats.(){
        testparams_nodes=(
            EthernetBytesSent
            EthernetBytesReceived
            EthernetPacketsSent
            EthernetPacketsReceived
            EthernetErrorsSent
            EthernetErrorsReceived
            EthernetUnicastPacketsSent
            EthernetUnicastPacketsReceived
            EthernetDiscardPacketsSent
            EthernetDiscardPacketsReceived
            EthernetMulticastPacketsSent
            EthernetMulticastPacketsReceived
            EthernetBroadcastPacketsSent
            EthernetBroadcastPacketsReceived
            EthernetUnknownProtoPacketsReceived
        )
        
        for ((i=0;i<${#testparams_nodes[@]};i++)); 
        do
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${testparams_nodes[i]}""\s*=\s*[0-9][0-9]*" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${testparams_nodes[i]}" >> $logpath/$currlogfilename
            fi
        done
    }
   
    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANIPConnection.x.Stats.(){
        testparams_nodes=(
            EthernetBytesSent
            EthernetBytesReceived
            EthernetPacketsSent
            EthernetPacketsReceived
            EthernetErrorsSent
            EthernetErrorsReceived
            EthernetUnicastPacketsSent
            EthernetUnicastPacketsReceived
            EthernetDiscardPacketsSent
            EthernetDiscardPacketsReceived
            EthernetMulticastPacketsSent
            EthernetMulticastPacketsReceived
            EthernetBroadcastPacketsSent
            EthernetBroadcastPacketsReceived
            EthernetUnknownProtoPacketsReceived
        )
        
        for ((i=0;i<${#testparams_nodes[@]};i++)); 
        do
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${testparams_nodes[i]}""\s*=\s*[0-9][0-9]*" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${testparams_nodes[i]}" >> $logpath/$currlogfilename
            fi
        done
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.CurrentProfile(){
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile=$CurrentProfile"                           >> $output

        cecho debug "connection type : VDSL"

        CurrentProfile_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile" |
                            awk -F= '{print $2}'`
        
        CurrentProfile_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "CurrentProfile_cli :$CurrentProfile_cli"
        cecho debug "CurrentProfile_mtv :$CurrentProfile_mtv"
        
        if [ "$CurrentProfile_cli" != "$CurrentProfile_mtv" ] ;then
            echo "$node2ser" >> $logpath/$currlogfilename
            let "result=$result+1"
        else 
            cecho debug "$CurrentProfile_cli"" matches ""$CurrentProfile_mtv"
        fi
    }




    InternetGatewayDevice.DeviceInfo.MemoryStatus.Total(){
    bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/cli_dut_dev_sysinfo.log
    MemoryStatusTotal_cli=`cat $G_CURRENTLOG/cli_dut_dev_sysinfo.log | grep "InternetGatewayDevice.DeviceInfo.MemoryStatus.Total" | awk -F= '{print $2}'`
    MemoryStatusTotal_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`


    echo debug "MemoryStatusTotal_cli:  $MemoryStatusTotal_cli"
    echo debug "MemoryStatusTotal_mtv:  $MemoryStatusTotal_mtv"       
    if [ "$MemoryStatusTotal_cli" != "$MemoryStatusTotal_mtv" ] ;then
            	 echo "$node2ser" >> $logpath/$currlogfilename
                 let "result=$result+1"
    	else
		echo debug "$MemoryStatusTotal_cli"" matches ""$MemoryStatusTotal_mtv"
    fi
}


   InternetGatewayDevice.DeviceInfo.MemoryStatus.Free(){
   bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/cli_dut_dev_sysinfo.log
    MemoryStatusFree_cli=`cat $G_CURRENTLOG/cli_dut_dev_sysinfo.log | grep "InternetGatewayDevice.DeviceInfo.MemoryStatus.Free" | awk -F= '{print $2}'`
    MemoryStatusFree_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`


    echo debug "MemoryStatusFree_cli:  $MemoryStatusFree_cli"
    echo debug "MemoryStatusFree_mtv:  $MemoryStatusFree_mtv"       
    if [ "$MemoryStatusFree_cli" != "$MemoryStatusFree_mtv" ] ;then
		in_range $MemoryStatusFree_cli $MemoryStatusFree_mtv $U_TR069_CUSTOM_MEMORYSTATUSRSFREE_RANGE
    else
		echo debug "$MemoryStatusFree_cli"" matches ""$MemoryStatusFree_mtv"
    fi
}
   

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.TotalBytesSent(){
    ###conn type###
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        TotalBytesSent_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent" |
                            awk -F= '{print $2}'`
        
        TotalBytesSent_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TotalBytesSent_cli :        $TotalBytesSent_cli"
        cecho debug "TotalBytesSent_mtv :        $TotalBytesSent_mtv"
        
        if [ "$TotalBytesSent_cli" != "$TotalBytesSent_mtv" ] ;then
            in_range $TotalBytesSent_cli $TotalBytesSent_mtv $TotalBytesSent_range
        else 
            cecho debug "$TotalBytesSent_cli"" matches ""$TotalBytesSent_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.TotalBytesReceived(){
    ###conn type###
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        TotalBytesReceived_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                                grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived" |
                                awk -F= '{print $2}'`

        TotalBytesReceived_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TotalBytesReceived_cli :        $TotalBytesReceived_cli"
        cecho debug "TotalBytesReceived_mtv :        $TotalBytesReceived_mtv"
        
        if [ "$TotalBytesReceived_cli" != "$TotalBytesReceived_mtv" ] ;then
            in_range $TotalBytesReceived_cli $TotalBytesReceived_mtv $TotalBytesReceived_range
        else 
            cecho debug "$TotalBytesReceived_cli"" matches ""$TotalBytesReceived_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.TotalPacketsSent(){
    ###conn type###
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        TotalPacketsSent_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent" |
                            awk -F= '{print $2}'`

        TotalPacketsSent_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TotalPacketsSent_cli :        $TotalPacketsSent_cli"
        cecho debug "TotalPacketsSent_mtv :        $TotalPacketsSent_mtv"
        
        if [ "$TotalPacketsSent_cli" != "$TotalPacketsSent_mtv" ] ;then
            in_range $TotalPacketsSent_cli $TotalPacketsSent_mtv $TotalPacketsSent_range
        else 
            cecho debug "$TotalPacketsSent_cli"" matches ""$TotalPacketsSent_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.TotalPacketsReceived(){
    ###conn type###
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        TotalPacketsReceived_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                                grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived" |
                                awk -F= '{print $2}'`

        TotalPacketsReceived_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TotalPacketsReceived_cli :        $TotalPacketsReceived_cli"
        cecho debug "TotalPacketsReceived_mtv :        $TotalPacketsReceived_mtv"
        
        if [ "$TotalPacketsReceived_cli" != "$TotalPacketsReceived_mtv" ] ;then
            in_range $TotalPacketsReceived_cli $TotalPacketsReceived_mtv $TotalPacketsReceived_range
        else 
            cecho debug "$TotalPacketsReceived_cli"" matches ""$TotalPacketsReceived_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.ACTINP(){
        cecho debug "not finished yet,sorry...this node have nerver been found in motive GPV log ...."
        let "result=$result+1"
    }


    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.WANAccessType(){
    ###conn type###
    ###range###
        if [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.3" ] ;then
            cecho debug "connection type : WAN ETHERNET"
            TotalPacketsReceived_cli="Ethernet"
        elif [ "$U_TR069_WANDEVICE_INDEX" != "InternetGatewayDevice.WANDevice.3" ] ;then
            cecho debug "connection type :WAN DSL"
            TotalPacketsReceived_cli="DSL"
        fi

        TotalPacketsReceived_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TotalPacketsReceived_cli :        $TotalPacketsReceived_cli"
        cecho debug "TotalPacketsReceived_mtv :        $TotalPacketsReceived_mtv"
        
        if [ "$TotalPacketsReceived_cli" != "$TotalPacketsReceived_mtv" ] ;then
            	 echo "$node2ser" >> $logpath/$currlogfilename
                 let "result=$result+1"
        else 
            cecho debug "$TotalPacketsReceived_cli"" matches ""$TotalPacketsReceived_mtv"
        fi
    }




    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DownstreamMaxRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate=$DownstreamMaxRate"                     >> $output

        DownstreamMaxRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate" |
                                awk -F= '{print $2}'`

        DownstreamMaxRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "DownstreamMaxRate_cli :     $DownstreamMaxRate_cli"
        cecho debug "DownstreamMaxRate_mtv :     $DownstreamMaxRate_mtv"
        if [ "$DownstreamMaxRate_cli" != "$DownstreamMaxRate_mtv" ] ;then
            in_range $DownstreamMaxRate_cli $DownstreamMaxRate_mtv $DownstreamMaxRate_range
        else 
            cecho debug "$DownstreamMaxRate_cli"" matches ""$DownstreamMaxRate_mtv"
        fi
    }
    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DownstreamPower(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower=$DownstreamPower"                         >> $output

        DownstreamPower_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower" |
                            awk -F= '{print $2}'`

        DownstreamPower_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        cecho debug "DownstreamPower_cli : ->              $DownstreamPower_cli"
        cecho debug "DownstreamPower_mtv : ->              $DownstreamPower_mtv"
        if [ "$DownstreamPower_cli" != "$DownstreamPower_mtv" ] ;then
            in_range $DownstreamPower_cli $DownstreamPower_mtv $DownstreamPower_range
        else 
            cecho debug "$DownstreamPower_cli"" matches ""$DownstreamPower_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UpstreamPower(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower=$UpstreamPower"                             >> $output

        UpstreamPower_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower" |
                        awk -F= '{print $2}'`

        UpstreamPower_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "UpstreamPower_cli : ->              $UpstreamPower_cli"
        cecho debug "UpstreamPower_mtv : ->              $UpstreamPower_mtv"

        if [ "$UpstreamPower_cli" != "$UpstreamPower_mtv" ] ;then
            in_range $UpstreamPower_cli $UpstreamPower_mtv $UpstreamPower_range
        else 
            cecho debug "$UpstreamPower_cli"" matches ""$UpstreamPower_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DownstreamAttenuation(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation=$DownstreamAttenuation"             >> $output

        DownstreamAttenuation_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                    grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation" |
                                    awk -F= '{print $2}'`

        DownstreamAttenuation_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "DownstreamAttenuation_cli : ->              $DownstreamAttenuation_cli"
        cecho debug "DownstreamAttenuation_mtv : ->              $DownstreamAttenuation_mtv"

        if [ "$DownstreamAttenuation_cli" != "$DownstreamAttenuation_mtv" ] ;then
            in_range $DownstreamAttenuation_cli $DownstreamAttenuation_mtv $DownstreamAttenuation_range
        else 
            cecho debug "$DownstreamAttenuation_cli"" matches ""$DownstreamAttenuation_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UpstreamAttenuation(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation=$UpstreamAttenuation"                 >> $output

        UpstreamAttenuation_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation" |
                                awk -F= '{print $2}'`

        UpstreamAttenuation_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "UpstreamAttenuation_cli : ->              $UpstreamAttenuation_cli"
        cecho debug "UpstreamAttenuation_mtv : ->              $UpstreamAttenuation_mtv"

        if [ "$UpstreamAttenuation_cli" != "$UpstreamAttenuation_mtv" ] ;then
            in_range $UpstreamAttenuation_cli $UpstreamAttenuation_mtv $UpstreamAttenuation_range
        else 
            cecho debug "$UpstreamAttenuation_cli"" matches ""$UpstreamAttenuation_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UpstreamNoiseMargin(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin=$UpstreamNoiseMargin"                 >> $output

        UpstreamNoiseMargin_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin" |
                                awk -F= '{print $2}'`

        UpstreamNoiseMargin_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "UpstreamNoiseMargin_cli : ->              $UpstreamNoiseMargin_cli"
        cecho debug "UpstreamNoiseMargin_mtv : ->              $UpstreamNoiseMargin_mtv"

        if [ "$UpstreamNoiseMargin_cli" != "$UpstreamNoiseMargin_mtv" ] ;then
            in_range $UpstreamNoiseMargin_cli $UpstreamNoiseMargin_mtv $UpstreamNoiseMargin_range
        else 
            cecho debug "$UpstreamNoiseMargin_cli"" matches ""$UpstreamNoiseMargin_mtv"
        fi
    }

    

    InternetGatewayDevice.WANDevice.x.WANConnectionDevice.x.WANDSLLinkConfig.(){
        values=(
            "Enable = true"
            "LinkStatus = Up"
            "LinkType = EoA"
            "AutoConfig = false"
            "ModulationType ="
            "DestinationAddress = PVC: $U_DUT_CUSTOM_VPI/$U_DUT_CUSTOM_VCI"
            "ATMEncapsulation = LLC"
            "ATMAAL = AAL5"
            "ATMTransmittedBlocks ="
            "ATMReceiveBlocks ="
            "ATMHECErrors ="
            "ATMQoS = UBR"
            "AAL5CRCErrors = 0"
            "ATMCRCErrors = 0"
            "ATMPeakCellRate = 0"
            "ATMMaximumBurstSize = 0"
            "ATMSustainableCellRate = 0"
        )

        for ((i=0;i<${#values[@]};i++)); 
        do
            #grep "$node2ser${values[i]}" $logpath/$dst
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${values[i]}" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${values[i]}" |awk '{print $1}'>> $logpath/$currlogfilename
            fi
        done
    }

    

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate=$Layer1UpstreamMaxBitRate"    >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate=$Layer1UpstreamMaxBitRate"  >> $output

        Layer1UpstreamMaxBitRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                    grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate" |
                                    awk -F= '{print $2}'`

        Layer1UpstreamMaxBitRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "Layer1UpstreamMaxBitRate_cli : ->              $Layer1UpstreamMaxBitRate_cli"
        cecho debug "Layer1UpstreamMaxBitRate_mtv : ->              $Layer1UpstreamMaxBitRate_mtv"

        if [ "$Layer1UpstreamMaxBitRate_cli" != "$Layer1UpstreamMaxBitRate_mtv" ] ;then
            in_range $Layer1UpstreamMaxBitRate_cli $Layer1UpstreamMaxBitRate_mtv $Layer1UpstreamMaxBitRate_range
        else 
            cecho debug "$Layer1UpstreamMaxBitRate_cli"" matches ""$Layer1UpstreamMaxBitRate_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        Layer1DownstreamMaxBitRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                        grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate" |
                                        awk -F= '{print $2}'`

        Layer1DownstreamMaxBitRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "Layer1DownstreamMaxBitRate_cli : ->              $Layer1DownstreamMaxBitRate_cli"
        cecho debug "Layer1DownstreamMaxBitRate_mtv : ->              $Layer1DownstreamMaxBitRate_mtv"

        if [ "$Layer1DownstreamMaxBitRate_cli" != "$Layer1DownstreamMaxBitRate_mtv" ] ;then
            in_range $Layer1DownstreamMaxBitRate_cli $Layer1DownstreamMaxBitRate_mtv $Layer1DownstreamMaxBitRate_range
        else 
            cecho debug "$Layer1DownstreamMaxBitRate_cli"" matches ""$Layer1DownstreamMaxBitRate_mtv"
        fi
    }

    

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.LinkEncapsulationUsed(){
    ###conn type###
        if [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.1" ] ;then
            cecho debug "connection type : ADSL"
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*G.992.3_Annex_K_ATM" -f $logpath/$dst
        elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.2" ] ;then
            cecho debug "connection type : VDSL"
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*G.992.3_Annex_K_PTM" -f $logpath/$dst
        fi
    }

    

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.TestParams.(){
        testparams_nodes=(
            HLOGGds
            HLOGGus
            HLOGpsds
            HLOGpsus
            HLOGMTds
            HLOGMTus
            QLNGds
            QLNGus
            QLNpsds
            QLNpsus
            QLNMTds
            QLNMTus
            SNRGds
            SNRGus
            SNRpsds
            SNRpsus
            SNRMTds
            SNRMTus
            LATNds
            LATNus
            SATNds
            SATNus
        )
        
        for ((i=0;i<${#testparams_nodes[@]};i++)); 
        do
            perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser${testparams_nodes[i]}""\s*=\s*[a-z0-9A-Z][a-z0-9A-Z]*" -f $logpath/$dst
            if [ $? -gt 0 ] ;then
                let "result=$result+1"
                echo "$node2ser${testparams_nodes[i]}" >> $logpath/$currlogfilename
            fi
        done
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.StandardsSupported(){
        possible_values=(
            G.992.1_Annex_A
            G.992.1_Annex_B
            G.992.1_Annex_C
            T1.413
            T1.413i2
            ETSI_101_388
            G.992.2
            G.992.3_Annex_A
            G.992.3_Annex_B
            G.992.3_Annex_C
            G.992.3_Annex_I
            G.992.3_Annex_J
            G.992.3_Annex_L
            G.992.3_Annex_M
            G.992.4
            G.992.5_Annex_A
            G.992.5_Annex_B
            G.992.5_Annex_C
            G.992.5_Annex_I
            G.992.5_Annex_J
            G.992.5_Annex_M
            G.993.1
            G.993.1_Annex_A
            G.993.2_Annex_A
            G.993.2_Annex_B
            G.993.2_Annex_C
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardsSupported : "$values
            echo "StandardsSupported : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "$value_count" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.StandardUsed(){
        possible_values=(
            G.992.1_Annex_A
            G.992.1_Annex_B
            G.992.1_Annex_C
            T1.413
            T1.413i2
            ETSI_101_388
            G.992.2
            G.992.3_Annex_A
            G.992.3_Annex_B
            G.992.3_Annex_C
            G.992.3_Annex_I
            G.992.3_Annex_J
            G.992.3_Annex_L
            G.992.3_Annex_M
            G.992.4
            G.992.5_Annex_A
            G.992.5_Annex_B
            G.992.5_Annex_C
            G.992.5_Annex_I
            G.992.5_Annex_J
            G.992.5_Annex_M
            G.993.1
            G.993.1_Annex_A
            G.993.2_Annex_A
            G.993.2_Annex_B
            G.993.2_Annex_C
        )
        
        match_count=0
        for ((i=0;i<${#possible_values[@]};i++)); 
        do
            values=`grep "$node2ser"  $logpath/$dst|awk -F = '{print $2}'|sed "s/,//g"`
            value_count=`echo "$values"|awk '{print NF}'`
            cecho debug "the count of value is :"$value_count
            echo "the count of value is :"$value_count>> $logpath/$currlogfilename".detail"
            cecho debug "StandardUsed : "$values
            echo "StandardUsed : "$values>> $logpath/$currlogfilename".detail"

            for ((i=0;i<${#possible_values[@]};i++)); 
            do
                echo "possible value :->         "${possible_values[i]}>> $logpath/$currlogfilename".detail"
            done

            for value in `echo $values`
            do
                cecho debug $value"-----------------"
                for ((i=0;i<${#possible_values[@]};i++)); 
                do
                    if [ ${possible_values[i]} == $value  ]; then
                        let "match_count=$match_count+1"
                        cecho debug "matched!"
                        echo "matched value :>              "$value>> $logpath/$currlogfilename".detail"
                    fi
                done
            done
        done
        cecho debug "final match count is :"$match_count
        if [ $match_count -gt 0 ] ;then
            if [ "$match_count" != "$value_count" ] ;then
                let "result=$result+1"
            fi
        else
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.ModulationType(){
    ###conn type###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType=$modulationType"                           >> $output

        modulation_type_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType" |
                            awk -F= '{print $2}'`

        modulation_type_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "modulation_type_cli : ->              $modulation_type_cli"
        cecho debug "modulation_type_mtv : ->              $modulation_type_mtv"

        if [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.1" ] ;then
            cecho debug "connection type : ADSL"
            
            if [ "$modulation_type_cli" == "ADSL2+" -a "$modulation_type_mtv" == "ADSL_2plus" ] ;then
                cecho debug "$modulation_type_cli"" matches ""$modulation_type_mtv"
            else 
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            fi
            
        elif [ "$U_TR069_WANDEVICE_INDEX" == "InternetGatewayDevice.WANDevice.2" ] ;then
            cecho debug "connection type : VDSL"
            
            if [ "$modulation_type_cli" != "$modulation_type_mtv" ] ;then
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            else 
                cecho debug "$modulation_type_cli"" matches ""$modulation_type_mtv"
            fi
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UpstreamMaxRate(){
    ###range###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate"                         >> $output

        UpstreamMaxRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate" |
                            awk -F= '{print $2}'`

        UpstreamMaxRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "UpstreamMaxRate_cli : ->              $UpstreamMaxRate_cli"
        cecho debug "UpstreamMaxRate_mtv : ->              $UpstreamMaxRate_mtv"

        if [ "$UpstreamMaxRate_cli" != "$UpstreamMaxRate_mtv" ] ;then
            in_range $UpstreamMaxRate_cli $UpstreamMaxRate_mtv $UpstreamMaxRate_range
        else 
            cecho debug "$UpstreamMaxRate_cli"" matches ""$UpstreamMaxRate_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DownstreamNoiseMargin(){
    ###range###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin=$DownstreamNoiseMargin"             >> $output

        DownstreamNoiseMargin_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin" |
                                awk -F= '{print $2}'`

        DownstreamNoiseMargin_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "DownstreamNoiseMargin_cli : ->              $DownstreamNoiseMargin_cli"
        cecho debug "DownstreamNoiseMargin_mtv : ->              $DownstreamNoiseMargin_mtv"

        if [ "$DownstreamNoiseMargin_cli" != "$DownstreamNoiseMargin_mtv" ] ;then
            in_range $DownstreamNoiseMargin_cli $DownstreamNoiseMargin_mtv $DownstreamNoiseMargin_range
        else 
            cecho debug "$DownstreamNoiseMargin_cli"" matches ""$DownstreamNoiseMargin_mtv"
        fi
    }

   InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.UpstreamCurrRate(){
   ###range###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate=$UpstreamCurrRate"                       >> $output

        UpstreamCurrRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate" |
                            awk -F= '{print $2}'`

        UpstreamCurrRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "UpstreamCurrRate_cli : ->              $UpstreamCurrRate_cli"
        cecho debug "UpstreamCurrRate_mtv : ->              $UpstreamCurrRate_mtv"

        if [ "$UpstreamCurrRate_cli" != "$UpstreamCurrRate_mtv" ] ;then
            in_range $UpstreamCurrRate_cli $UpstreamCurrRate_mtv $UpstreamCurrRate_range
        else 
            cecho debug "$UpstreamCurrRate_cli"" matches ""$UpstreamCurrRate_mtv"
        fi
    }
	
   InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.DownstreamCurrRate(){
   ###range###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate=$DownstreamCurrRate"                   >> $output

        DownstreamCurrRate_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate" |
                                awk -F= '{print $2}'`

        DownstreamCurrRate_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "DownstreamCurrRate_cli : ->              $DownstreamCurrRate_cli"
        cecho debug "DownstreamCurrRate_mtv : ->              $DownstreamCurrRate_mtv"

        if [ "$DownstreamCurrRate_cli" != "$DownstreamCurrRate_mtv" ] ;then
            in_range $DownstreamCurrRate_cli $DownstreamCurrRate_mtv $DownstreamCurrRate_range
        else 
            cecho debug "$DownstreamCurrRate_cli"" matches ""$DownstreamCurrRate_mtv"
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.TRELLISds(){
    ###check###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds=$TRELLISds"                                     >> $output

        TRELLISds_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds" |
                        awk -F= '{print $2}'`

        TRELLISds_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TRELLISds_cli : ->              $TRELLISds_cli"
        cecho debug "TRELLISds_mtv : ->              $TRELLISds_mtv"

        if [  "$TRELLISds_cli" == "U:ON" ] ;then
            if [ "$TRELLISds_mtv" == "1" ] ;then
                cecho debug "$TRELLISds_cli matches $TRELLISds_mtv"
            else
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            fi
        elif [  "$TRELLISds_cli" == "D:OFF" ] ;then
            if [ "$TRELLISds_mtv" == "-1" -o "$TRELLISds_mtv" == "0" ] ;then
                cecho debug "$TRELLISds_cli matches $TRELLISds_mtv"
            else
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            fi
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.TRELLISus(){
    ###check###
	    bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus=$TRELLISus"                                     >> $output

        TRELLISus_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus" |
                        awk -F= '{print $2}'`

        TRELLISus_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "TRELLISus_cli : ->              $TRELLISus_cli"
        cecho debug "TRELLISus_mtv : ->              $TRELLISus_mtv"

        if [  "$TRELLISus_cli" == "U:ON" ] ;then
            if [ "$TRELLISus_mtv" == "1" ] ;then
                cecho debug "$TRELLISus_cli matches $TRELLISus_mtv"
            else
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            fi
        elif [  "$TRELLISus_cli" == "D:OFF" ] ;then
            if [ "$TRELLISus_mtv" == "-1" -o "$TRELLISus_mtv" == "0" ] ;then
                cecho debug "$TRELLISus_cli matches $TRELLISus_mtv"
            else
                echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            fi
        fi
    }

    InternetGatewayDevice.WANDevice.x.WANDSLInterfaceConfig.PowerManagementState(){
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState=$PowerManagementState"               >> $output

        PowerManagementState_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState" |
                                awk -F= '{print $2}'`

        PowerManagementState_mtv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        cecho debug "PowerManagementState_cli : ->              $PowerManagementState_cli"
        cecho debug "PowerManagementState_mtv : ->              $PowerManagementState_mtv"

        if [ "$PowerManagementState_cli" != "$PowerManagementState_mtv" ] ;then
            echo "$node2ser" >> $logpath/$currlogfilename
            let "result=$result+1"
        else 
            cecho debug "$PowerManagementState_cli matches $PowerManagementState_mtv"
        fi
    }

    
    #given_value_node
    method=`echo $node2ser |sed "s/\.[0-9]\{1,\}/\.x/g"`

    cecho debug "single node mode -> special"

    for ((i=0;i<${#given_value_node[@]};i++)); 
    do
        given_node=`echo ${given_value_node[i]} |awk -F= '{print $1}'`
        given_value=`echo ${given_value_node[i]} |awk -F= '{print $2}'`
        if [ "$given_node" == "$method"  ]; then
            #cecho debug "funtion to be executed : givenValue"
            method="givenValue $given_value"
        #else
            #cecho debug "funtion to be executed : "$method
            #method
        fi
    done
    
    cecho debug "funtion to be executed : "$method
    $method
    
    if [ $? -gt 0 ] ;then
        let "result=$result+1"
        cecho debug "$node2ser"
        echo "$node2ser" >> $logpath/$currlogfilename
    fi

    #echo -e "\n"

}


common(){
    cecho debug "single node mode"
    perl $U_PATH_TBIN/searchoperation.pl '-e' "$node2ser""\s*=\s*[a-z0-9A-Z][a-z0-9A-Z]*" -f $logpath/$dst
    if [ $? -gt 0 ] ;then
        let "result=$result+1"
        cecho debug "$node2ser"
        echo "$node2ser" >> $logpath/$currlogfilename
    fi
    
    echo -e "\n"
}

out="multi_search_in_file.log"

flag=0

TotalBytesSent_range=1000000
TotalBytesReceived_range=80000
TotalPacketsSent_range=1000
TotalPacketsReceived_range=1000
DownstreamMaxRate_range=50
DownstreamPower_range=1
UpstreamPower_range=5
DownstreamAttenuation_range=1
UpstreamAttenuation_range=1
UpstreamNoiseMargin_range=1
Layer1UpstreamMaxBitRate_range=50
Layer1DownstreamMaxBitRate_range=50
UpstreamMaxRate_range=50
DownstreamNoiseMargin_range=1
UpstreamCurrRate_range=1
DownstreamCurrRate_range=1

while [ -n "$1" ];
do
    case "$1" in
        -node)
            node2ser=$2
            echo "the node to be searched in GPV log is ${node2ser}"
            shift 2
            ;;
        -e)
            src=$2
            echo "the source file is ${src}"
            shift 2
            ;;
        -ex)
            exp=$2
            echo "the expect file is ${exp}"
            shift 2
            ;;
        -f)
            dst=$2
            echo "the desti file is ${dst}"
            shift 2
            ;;
        -out)
            out=$2
            echo "the log file is ${out}"
            shift 2
            ;;
        -l)
            logpath=$2
            echo "the log path is ${logpath}"
            shift 2
            ;;
        -n)
            flag=1
            echo "with one error,test error"
            shift 1
            ;;
        -test)
            U_PATH_TBIN=./
            G_CURRENTLOG=/tmp
            shift 1
            ;;
        -h)
            USAGE
            exit 1
            ;;
        -*)
            cecho debug $usage
            exit 1
            ;;
    esac
done

if [ -z $logpath ] ;then
    logpath=$G_CURRENTLOG
fi

result=0

createlogname $out
cecho debug "current logfile name is : "$currlogfilename

if [ "$node2ser" != "" ] ;then
switch
elif [  "$src" != "" ] ;then
    cecho debug "nodes in a file mode"
    cat $logpath/$src |while read line
    do
        cecho debug "line ------->"$line
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$line" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
            #let "result=$result+1"
            echo "$line" >> $logpath/$currlogfilename
        fi
        echo -e "\n"
        echo -e "\n"
    done
    if [ -f $logpath/$currlogfilename ] ;then
        let "result=$result+1"
    fi
elif [ "$exp" != "" ] ;then
    cecho debug "nodes in a expect file mode"
    for foo in `cat $logpath/$exp`
    do
        cecho debug "expect value :"$foo
        perl $U_PATH_TBIN/searchoperation.pl '-e' "$foo" -f $logpath/$dst
        if [ $? -gt 0 ] ;then
            let "result=$result+1"
            echo "$foo" >> $logpath/$currlogfilename
        fi
        echo -e "\n"
        echo -e "\n"
    done
fi

detailedLog

cecho debug "the final result is ${result}"

if [ $flag -eq 0 ] ;then
    cecho debug "positive test "
    exit $result
else
    if [ $result -eq 0 ] ;then
        cecho debug "negative test : result -- NG"
        exit 1
    else
        cecho debug "negative test : result -- OK"
        exit 0
    fi
fi
