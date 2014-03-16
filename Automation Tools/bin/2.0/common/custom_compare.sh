#!/bin/bash

# Author        :
# Description   :
#   This tool is using
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#29 Nov 2011    |   1.0.0   | Howard    | Inital Version
#06 Dec 2011    |   1.0.1   | Howard    | Fine tuned log system
#09 Dec 2011    |   1.0.2   | Alex      | Add function for CurrentLocalTime LocalTimeZone and LocalTimeZoneName
#09 Dec 2011    |   1.0.3   | Howard    | removed the step that copy the GPV log to current log folder
#12 Dec 2011    |   1.0.4   | Alex      | Add function for the cases which only check result of GPV

VER="1.0.4"
echo "$0 version : ${VER}"

usage="bash $0 -f <destination file> -out <log file name> -l <log dir> -node <node> [-n]"

USAGE()
{
    cat <<usge
USAGE :

    bash $0 -e <source file> -f <destination file> -out <log file name> -l <log dir> -node <node>

OPTIONS:
    -f:     the file that to be conpaired with,usually is the GPV log file
    -out:   log file name,just the file name!
    -l:     log file path,just the path!
    -node:  the Node to be check
    -n:     negative mode

NOTES :

    1.if you DON'T run this script in testcase , please put [-test] option in front of all the other options
    2.the [-l] and [-out] parameter can be omitted,in that case,the log will be in \$G_CURRENTLOG
    3.the [-f] will defaultly considered in \$G_CURRENTLOG,if you want to use file in other path,please let me know

EXAMPLES:

    bash $0 -test -f <destination file> -out <log file name> -l <log dir> -node <node> [-n]
usge
}

createlogname(){
    lognamex=$1
    #cecho debug "ls $logpath/$lognamex*"
    ls $logpath/$lognamex* 2> /dev/null

    if [  $? -gt 0 ]; then
        #cecho debug "file not exists"
        #cecho debug "so the current file to be created is : "$lognamex""_"1"
        currlogfilename=$lognamex"_""1"
    else
        #cecho debug "file exists"
        curr=`ls $logpath/$lognamex*|wc -l`
        let "next=$curr+1"
        #cecho debug "so the current file to be created is : "$lognamex"_"$next
        currlogfilename=$lognamex"_"$next
    fi
}

GPV2(){
    echo "in GPV2 : curr_node2ser -> $curr_node2ser"

    rc=`echo $curr_node2ser|grep -o "LastChange" `
    echo "rc=$rc"
    if [ $rc = "LastChange" ]; then
        special
    else

        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        dst2=$dst"_1"

        rule_gpv2=`grep "$curr_node2ser " $logpath/$dst2 |awk -F = '{print $2}'|sed "s/ //g"`

        rule_value="U_GPV2_"$current_case"_"$current_node

        export $rule_value=$rule_gpv2
    fi

}

needCLI(){
##########################################    copied from multi    ##########################################
##########################################          start          ##########################################
##########################################    copied from multi    ##########################################

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.CurrentProfile(){
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile=$CurrentProfile"                           >> $output

        cecho debug "connection type : VDSL"

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.CurrentProfile" |
                            awk -F= '{print $2}'`
        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv


    }

#    InternetGatewayDevice.DeviceInfo.MemoryStatus.Total(){
#        bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/cli_dut_dev_sysinfo.log
#        rule_cli=`cat $G_CURRENTLOG/cli_dut_dev_sysinfo.log | grep "InternetGatewayDevice.DeviceInfo.MemoryStatus.Total" | awk -F= '{print $2}'`
#        rule_value="U_CLI_"$current_case"_"$current_node
#        export $rule_value=$rule_cli
#
#        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
#
#        final_rule=$final_rule" -r \$"$rule
#
#        echo "now the rule to pass to python is $final_rule"
#
#        export $rule=$rule_gpv
#
#    }

#    InternetGatewayDevice.DeviceInfo.MemoryStatus.Free(){
#        bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/cli_dut_dev_sysinfo.log
#        rule_cli=`cat $G_CURRENTLOG/cli_dut_dev_sysinfo.log | grep "InternetGatewayDevice.DeviceInfo.MemoryStatus.Free" | awk -F= '{print $2}'`
#        rule_value="U_CLI_"$current_case"_"$current_node
#        export $rule_value=$rule_cli
#
#        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
#
#        final_rule=$final_rule" -r \$"$rule
#
#        echo "now the rule to pass to python is $final_rule"
#
#        export $rule=$rule_gpv
#
#    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.TotalBytesSent(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent" |
                            awk -F= '{print $2}'`
        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.TotalBytesReceived(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                                grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived" |
                                awk -F= '{print $2}'`
        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli


        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.TotalPacketsSent(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent" |
                            awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.TotalPacketsReceived(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesSent=$TotalBytesSent"                        >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalBytesReceived=$TotalBytesReceived"                >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsSent=$TotalBytesReceived"                  >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived=$TotalPacketsReceived"            >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                                grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.TotalPacketsReceived" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.DownstreamMaxRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate=$DownstreamMaxRate"                     >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamMaxRate" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.ACTINP(){
    #
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ACTINP" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.DownstreamPower(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower=$DownstreamPower"                         >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamPower" |
                            awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.UpstreamPower(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower=$UpstreamPower"                             >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamPower" |
                        awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.DownstreamAttenuation(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation=$DownstreamAttenuation"             >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                    grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamAttenuation" |
                                    awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.UpstreamAttenuation(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation=$UpstreamAttenuation"                 >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamAttenuation" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.UpstreamNoiseMargin(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin=$UpstreamNoiseMargin"                 >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamNoiseMargin" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate=$Layer1UpstreamMaxBitRate"    >> $output
        #   echo "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate=$Layer1UpstreamMaxBitRate"  >> $output

        echo "cat $G_CURRENTLOG/cli_dut_wan_stats.log  |grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate" |awk -F= '{print \$2}'"

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                    grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1UpstreamMaxBitRate" |
                                    awk -F= '{print $2}'`

        #if [ "$U_DUT_TYPE" == "CTLC2KA" ] ;then
        #    rule_cli=`echo "$rule_cli*1000"|bc`
        #fi

        echo "rule_cli is : ${rule_cli}"

        rule_value="U_CLI_"$current_case"_"$current_node

        echo "export $rule_value=$rule_cli"
        export $rule_value=$rule_cli

        echo "grep "$node2ser" $logpath/$dst |awk -F = '{print \$2}'|sed "s/ //g""

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        echo "rule_gpv is : ${rule_gpv}"

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        echo "export $rule=$rule_gpv"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                        grep "$U_TR069_WANDEVICE_INDEX.WANCommonInterfaceConfig.Layer1DownstreamMaxBitRate" |
                                        awk -F= '{print $2}'`

        #if [ "$U_DUT_TYPE" == "CTLC2KA" ] ;then
        #    rule_cli=`echo "$rule_cli*1000"|bc`
        #fi

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.ModulationType(){
    ###conn type###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType=$modulationType"                           >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.ModulationType" |
                            awk -F= '{print $2}'`

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

    #    if [ "$U_TMP_WAN_CONNECTION_TYPE" == "ADSL" ] ;then
    #        cecho debug "connection type : ADSL"
    #
    #        if [ "$rule_cli" == "ADSL2+" -a "$rule_gpv" == "ADSL_2plus" ] ;then
    #            rule_cli=$rule_gpv
    #        fi

    #    elif [ "$U_TMP_WAN_CONNECTION_TYPE" == "VDSL" ] ;then
    #        cecho debug "connection type : VDSL"
    #    else
    #        cecho error "WAN connection type :expect ADSL and VDSL"
    #        cecho error "WAN connection type :$U_TMP_WAN_CONNECTION_TYPE"
    #
    #    fi

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli
    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.UpstreamMaxRate(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate"                         >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamMaxRate=$UpstreamMaxRate" |
                            awk -F= '{print $2}'`

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        if [ "$UpstreamMaxRate_cli" != "$UpstreamMaxRate_mtv" ] ;then
            in_range $UpstreamMaxRate_cli $UpstreamMaxRate_mtv $UpstreamMaxRate_range
        else
            cecho debug "$UpstreamMaxRate_cli"" matches ""$UpstreamMaxRate_mtv"
        fi

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.DownstreamNoiseMargin(){
    ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin=$DownstreamNoiseMargin"             >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamNoiseMargin" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.UpstreamCurrRate(){
   ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate=$UpstreamCurrRate"                       >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                            grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.UpstreamCurrRate" |
                            awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

   InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.DownstreamCurrRate(){
   ###range###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate=$DownstreamCurrRate"                   >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.DownstreamCurrRate" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.TRELLISds(){
    ###check###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds=$TRELLISds"                                     >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISds" |
                        awk -F= '{print $2}'`

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`


        echo "$rule_cli" | grep -i "on"

        rc_on=$?

        echo "$rule_cli" | grep -i "off"

        rc_off=$?


        if [  "$rc_on" == "0" ] ;then
            if [ "$rule_gpv" == "1" ] ;then
                rule_cli="1"
            fi
        elif [  "$rc_off" == "0" ] ;then
            if [ "$rule_gpv" == "-1" -o "$rule_gpv" == "0" ] ;then
                rule_cli=$rule_gpv
            fi
        fi

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli
    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.TRELLISus(){
    ###check###
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus=$TRELLISus"                 >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                        grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.TRELLISus" |
                        awk -F= '{print $2}'`

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        echo "$rule_cli" | grep -i "on"

        rc_on=$?

        echo "$rule_cli" | grep -i "off"

        rc_off=$?


        if [  "$rc_on" == "0" ] ;then
            #if [ "$rule_gpv" == "1" ] ;then
                rule_cli="1"
            #fi
        elif [  "$rc_off" == "0" ] ;then
            if [ "$rule_gpv" == "-1" -o "$rule_gpv" == "0" ] ;then
                rule_cli=$rule_gpv
            fi
        fi

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.PowerManagementState(){
        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log
        #   echo "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState=$PowerManagementState"               >> $output

        rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log  |
                                grep "$U_TR069_WANDEVICE_INDEX.WANDSLInterfaceConfig.PowerManagementState" |
                                awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node
        export $rule_value=$rule_cli

        rule_gpv=`grep "$node2ser" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

    }


##########################################    copied from multi     ##########################################
##########################################           end            ##########################################
##########################################    copied from multi     ##########################################

    InternetGatewayDevice.DeviceInfo.X_ACTIONTEC_MemoryUsed(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/sysinfo.log

        rule_cli=`cat $G_CURRENTLOG/sysinfo.log  |grep "MemoryUsed" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.TotalBytesSent(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wifi.stats -o $G_CURRENTLOG/wifi.stats.log

        rule_cli=`cat $G_CURRENTLOG/wifi.stats.log  |grep "TotalBytesSent" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.TotalBytesReceived(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wifi.stats -o $G_CURRENTLOG/wifi.stats.log

        rule_cli=`cat $G_CURRENTLOG/wifi.stats.log  |grep "TotalBytesReceived" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.TotalPacketsSent(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wifi.stats -o $G_CURRENTLOG/wifi.stats.log

        rule_cli=`cat $G_CURRENTLOG/wifi.stats.log  |grep "TotalPacketsSent" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.TotalPacketsReceived(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wifi.stats -o $G_CURRENTLOG/wifi.stats.log

        rule_cli=`cat $G_CURRENTLOG/wifi.stats.log  |grep "TotalPacketsReceived" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.DeviceInfo.MemoryStatus.Total(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/sysinfo.log

        rule_cli=`cat $G_CURRENTLOG/sysinfo.log  |grep "Total=" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli


    }
    InternetGatewayDevice.DeviceInfo.MemoryStatus.Free(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v dev.sysinfo -o $G_CURRENTLOG/sysinfo.log

        rule_cli=`cat $G_CURRENTLOG/sysinfo.log  |grep "Free=" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli


    }
    InternetGatewayDevice.Time.CurrentLocalTime(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        echo "GPV: $rule_gpv"
        date_gpvq=`echo $rule_gpv|grep -o "[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}"`

        date_gpv[0]=`echo "$date_gpvq"|awk -F -  '{print $1*1440*365}'`
        date_gpv[1]=`echo "$date_gpvq"|awk -F -  '{print $2*1440*30}'`
        date_gpv[2]=`echo "$date_gpvq"|awk -F -  '{print $3*1440}'`

        time_gpvq=`echo $rule_gpv|grep -o "[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}"`
        time_gpv[0]=`echo "$time_gpvq"|awk -F : '{print $1*60}'`
        time_gpv[1]=`echo "$time_gpvq"|awk -F : '{print $2}'`

        rule_gpv=` expr ${date_gpv[0]} + ${date_gpv[1]} + ${date_gpv[2]} + ${time_gpv[0]} + ${time_gpv[1]} `
        echo "CurrentLocalTime_gpv=$rule_gpv"

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        echo "rule=$rule_gpv"
        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v dut.date -o $G_CURRENTLOG/dut.date.log

        rule_cli=`cat $G_CURRENTLOG/dut.date.log  |grep "U_CUSTOM_LOCALTIME" |awk -F= '{print $2}'`

        date_cli[0]=`echo "$rule_cli"|awk '{print $NF*1440*365}'`
        date_cli[1]=`echo "$rule_cli"|awk '{print $2}'`
        date_cli[2]=`echo "$rule_cli"|awk '{print $3*1440}'`
        time_tmp=`echo "$rule_cli"|awk '{print $4}'`
        time_cli[0]=`echo "$time_tmp"|awk -F : '{print $1*60}'`
        time_cli[1]=`echo "$time_tmp"|awk -F : '{print $2}'`

        echo "${date_cli[0]} ${date_cli[1]} ${date_cli[2]} ${time_cli[0]} ${time_cli[1]}"

        mon_tmp=''
        rate=43200
        echo "${date_cli[1]}"
        if [ "${date_cli[1]}" = "Jan" ]; then
            mon_tmp=1
        elif [ "${date_cli[1]}" = "Feb" ]; then
            mon_tmp=2
        elif [ "${date_cli[1]}" = "Mar" ]; then
            mon_tmp=3
        elif [ "${date_cli[1]}" = "Apr" ]; then
            mon_tmp=4
        elif [ "${date_cli[1]}" = "May" ]; then
            mon_tmp=5
        elif [ "${date_cli[1]}" = "Jun" ]; then
            mon_tmp=6
        elif [ "${date_cli[1]}" = "Jul" ]; then
            mon_tmp=7
        elif [ "${date_cli[1]}" = "Aug" ]; then
            mon_tmp=8
        elif [ "${date_cli[1]}" = "Sept" ]; then
            mon_tmp=9
        elif [ "${date_cli[1]}" = "Oct" ]; then
            mon_tmp=10
        elif [ "${date_cli[1]}" = "Nov" ]; then
            mon_tmp=11
        elif [ "${date_cli[1]}" = "Dec" ]; then
            mon_tmp=12
        else
            mon_tmp=0
        fi
        echo "$mon_tmp"
        date_cli[1]=`expr ${mon_tmp} \* ${rate}`

        rule_cli=`expr ${date_cli[0]} + ${date_cli[1]} + ${date_cli[2]} + ${time_cli[0]} + ${time_cli[1]}`
        echo "CurrentLocalTime_cli=$rule_cli"

        rule_value="U_CLI_"$current_case"_"$current_node

        echo "rule_value=$rule_cli"
        export $rule_value=$rule_cli
        echo "$rule_value=$rule_cli"

    }
    InternetGatewayDevice.Time.LocalTime(){
        currentTime_gpv=`grep "InternetGatewayDevice.Time.CurrentLocalTime " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        TimeZone_gpv=`grep "InternetGatewayDevice.Time.LocalTimeZone " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`
        echo "GPV: $currentTime_gpv $TimeZone_gpv"
        sign=`echo $TimeZone_gpv | cut -c 1`
        TimeZone=`echo $TimeZone_gpv | cut -c 2,3 |sed "s/^0//g"`
        echo "TimeZone : $TimeZone"

        date_gpvq=`echo $currentTime_gpv|grep -o "[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}"`
        date_gpv[0]=`echo "$date_gpvq"|awk -F -  '{print $1*1440*365}'`
        date_gpv[1]=`echo "$date_gpvq"|awk -F -  '{print $2*1440*30}'`
        date_gpv[2]=`echo "$date_gpvq"|awk -F -  '{print $3*1440}'`

        time_gpvq=`echo $currentTime_gpv|grep -o "[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}"`
        time_gpv[0]=`echo "$time_gpvq"|awk -F : '{print $1*60}'`
        time_gpv[1]=`echo "$time_gpvq"|awk -F : '{print $2}'`

        currentTime_gpv=` expr ${date_gpv[0]} + ${date_gpv[1]} + ${date_gpv[2]} + ${time_gpv[0]} + ${time_gpv[1]} `
        echo "currentTime_gpv=$currentTime_gpv"

        rate=60
        offset=`expr ${TimeZone} \* ${rate}`
        echo "offset=$offset"

        if [ $U_CUSTOM_DAYLIGHT_SAVING_TIME_ENABLE = 1 ]; then
            offset=`echo "$offset-60" | bc`
        fi

        if [ "$sign" == "+" ]; then
            rule_gpv=`expr ${currentTime_gpv} - ${offset}`
        elif [ "$sign" == "-" ]; then
            rule_gpv=`expr ${currentTime_gpv} + ${offset}`
        fi

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        echo "rule=$rule_gpv"
        export $rule=$rule_gpv

        echo "ntpdate $G_HOST_IP1"
        ntpdate $G_HOST_IP1
        rule_cli=`date -u`
        echo "EXPECTRD: $rule_cli"

        date_cli[0]=`echo "$rule_cli"|awk '{print $6*1440*365}'`
        date_cli[1]=`echo "$rule_cli"|awk '{print $2}'`
        date_cli[2]=`echo "$rule_cli"|awk '{print $3*1440}'`
        time_tmp=`echo "$rule_cli"|awk '{print $4}'`
        time_cli[0]=`echo "$time_tmp"|awk -F : '{print $1*60}'`
        time_cli[1]=`echo "$time_tmp"|awk -F : '{print $2}'`

        mon_tmp=''
        rate=43200
        echo "${date_cli[1]}"
        if [ "${date_cli[1]}" = "Jan" ]; then
            mon_tmp=1
        elif [ "${date_cli[1]}" = "Feb" ]; then
            mon_tmp=2
        elif [ "${date_cli[1]}" = "Mar" ]; then
            mon_tmp=3
        elif [ "${date_cli[1]}" = "Apr" ]; then
            mon_tmp=4
        elif [ "${date_cli[1]}" = "May" ]; then
            mon_tmp=5
        elif [ "${date_cli[1]}" = "Jun" ]; then
            mon_tmp=6
        elif [ "${date_cli[1]}" = "Jul" ]; then
            mon_tmp=7
        elif [ "${date_cli[1]}" = "Aug" ]; then
            mon_tmp=8
        elif [ "${date_cli[1]}" = "Sept" ]; then
            mon_tmp=9
        elif [ "${date_cli[1]}" = "Oct" ]; then
            mon_tmp=10
        elif [ "${date_cli[1]}" = "Nov" ]; then
            mon_tmp=11
        elif [ "${date_cli[1]}" = "Dec" ]; then
            mon_tmp=12
        else
            mon_tmp=0
        fi
        echo "$mon_tmp"
        date_cli[1]=`expr ${mon_tmp} \* ${rate}`

        rule_cli=`expr ${date_cli[0]} + ${date_cli[1]} + ${date_cli[2]} + ${time_cli[0]} + ${time_cli[1]}`
        echo "currentTime_cli=$rule_cli"

        rule_value="U_CLI_"$current_case"_"$current_node

        echo "rule_value=$rule_cli"
        export $rule_value=$rule_cli
        echo "$rule_value=$rule_cli"

    }
    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.BSSID(){
        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wl.mac -o $G_CURRENTLOG/wl.mac.log

        rule_cli=`cat $G_CURRENTLOG/wl.mac.log  |grep "TMP_DUT_WIRELESS_BSSID"$rule_index |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.AssociatedDevice.i.AssociatedDeviceMACAddress(){

        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wireless.conf -o $G_CURRENTLOG/wireless_conf.log

        rule_cli=`cat $G_CURRENTLOG/wireless_conf.log  |grep "AssociatedDeviceMACAddress" |awk -F= '{print $2}'| tr [A-Z] [a-z]`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli


    }
    InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.AssociatedDevice.i.AssociatedDeviceIPAddress(){

        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        bash $U_PATH_TBIN/cli_dut.sh -v wireless.conf -o $G_CURRENTLOG/wireless_conf.log

        rule_cli=`cat $G_CURRENTLOG/wireless_conf.log  |grep "AssociatedDeviceIPAddress" |awk -F= '{print $2}'`

        rule_value="U_CLI_"$current_case"_"$current_node

        export $rule_value=$rule_cli

    }


    method=`echo $curr_node2ser |sed "s/\.[0-9]\{1,\}/\.i/g" |sed "s/$U_TR069_CUSTOM_MANUFACTUREROUI/ACTIONTEC/g"`

    $method

    rc_cmd=$?

    if [ $rc_cmd -gt 0 ] ;then
        let "result=$result+1"
    fi

}

common(){
    echo "entering function common() ..."
    # rule="U_GPV_"$current_case"_"$current_node
    echo "grep $curr_node2ser  $logpath/$dst |awk -F = '{print $2}'"

    rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/^ //g"`
    echo "rule_gpv is : $rule_gpv"

    final_rule=$final_rule" -r \$"$rule

    echo "now the rule to pass to python is $final_rule"

    echo "export $rule=$rule_gpv"

    export $rule="$rule_gpv"

}

special(){
    echo "special"

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANPPPConnection.i.PortMappingNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst
        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANIPConnection.i.PortMappingNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst
        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.LANDeviceNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n LANDeviceNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n LANDeviceNumberOfEntries -i $dst

        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.WANDeviceNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n WANDeviceNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n WANDeviceNumberOfEntries -i $dst
        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.UserNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n UserNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n UserNumberOfEntries -i $dst
        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.DeviceInfo.ProcessStatus.ProcessNumberOfEntries(){
        echo "bash $U_PATH_TBIN/checkNumberOfObject.sh -n ProcessNumberOfEntries -i $dst"
        bash $U_PATH_TBIN/checkNumberOfObject.sh -n ProcessNumberOfEntries -i $dst
        rc_special=$?

        if [ $rc_special -ne 0 ] ;then
            echo "FAILED in special function !" >> $G_CURRENTLOG/$currlogfilename
            let "result=$result+1"
        elif [ $rc_special -eq 0 ] ;then
            echo "PASSED in special function !" >> $G_CURRENTLOG/$currlogfilename
        fi
    }

    InternetGatewayDevice.LANDevice.i.WLANConfiguration.(){
        echo "InternetGatewayDevice.LANDevice.i.WLANConfiguration.........."
        rule_index=1
        for rule_cfg in `grep -o "^$rule[^ ]*" $U_CUSTOM_TR_RULE_FILE`
        do
            echo "rule_cfg is : $rule_cfg"
            rule=`echo $rule_cfg|awk '{print $1}'`

            gpv_node="$curr_node2ser""$rule_index"".SSID "
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            final_rule=" -r \$"$rule

            echo "export $rule=$rule_gpv"

            export $rule=$rule_gpv


            echo "python $U_PATH_TBIN/custom_compare.py $final_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
            python $U_PATH_TBIN/custom_compare.py $final_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename
            let "rule_index=$rule_index+1"

            compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

            if [ "$compare_rc" == "TRUE" ] ;then
                echo "custom_compare.py passed !"
            elif [ "$compare_rc" == "FALSE" ] ;then
                echo "custom_compare.py failed !"
            #echo "$node2ser" >> $logpath/$currlogfilename
                let "result=$result+1"
            #elif [ "$compare_rc" == "NONE" ] ;then
               # special
               # rc=$?
                #if [ $rc -eq 127 ] ;then
                #    echo "rule not found ! please add this rule in $U_CUSTOM_TR_RULE_FILE if needed!"
                #    let "result=$result+1"
                #fi
            else
                echo "what happened: $compare_rc"
                let "result=$result+1"
            fi

        done

    }

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANPPPConnection.i.Stats.(){
        stats_rule=""
        stats=(
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

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANIPConnection.i.Stats.(){
        stats_rule=""
        stats=(
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

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

    #InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANPPPConnection.i.PortMappingNumberOfEntries(){
    #    bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst
    #    if [ $? -ne 0 ] ;then
    #        let "result=$result+1"
    #    fi

    #}

    #InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANIPConnection.i.PortMappingNumberOfEntries(){
    #    bash $U_PATH_TBIN/checkNumberOfObject.sh -n PortMappingNumberOfEntries -i $dst
    #    if [ $? -ne 0 ] ;then
    #        let "result=$result+1"
    #    fi
    #}

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANPPPConnection.i.(){
        stats=(
         PPPoESessionID                 #   =   Session ID of current PPP connection
         DefaultGateway                 #   =   IP Address obtained from WAN PPPoE server.
         Username                       #   =   PPP username you used to establish the PPPoE connection.
         Password                       #   =   Empty
         PPPEncryptionProtocol          #   =   Empty
         PPPCompressionProtocol         #   =   Empty
         PPPAuthenticationProtocol      #   =   AUTO_AUTH
         ExternalIPAddress              #   =   IP Address assigned on PPP interface.
         RemoteIPAddress                #   =   Value of Default Gateway
         CurrentMRUSize                 #   =   1492
         MaxMRUSize                     #   =   0
         DNSEnabled                     #   =   ture
         DNSOverrideAllowed             #   =   false
         DNSServers                     #   =   IP address(es) of DNS server assigned by WAN PPPoE server
         MACAddress                     #   =   MAC address equipped on atm0 interface.
         MACAddressOverride             #   =   false
         TransportType                  #   =   PPPoE
         PPPoEACName                    #   =   PPPoE Access Concentrator.
         PPPoEServiceName               #   =   PPPoE Service Name
         RouteProtocolRx                #   =   OFF
         PPPLCPEcho                     #   =   PPP LCP Echo period in seconds.
         PPPLCPEchoRetry                #   =   Number of PPP LCP Echo retries within an echo period.
        )

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANIPConnection.i.(){
        stats=(
            AddressingType      #   =   DHCP
            ExternalIPAddress   #   =   DUT's WAN IP Address obtained from WAN DHCP server
            SubnetMask          #   =   DUT's WAN Subnet Mask obtained from WAN DHCP server
            DefaultGateway      #   =   DUT's WAN Default Gateway obtained from WAN DHCP server
            DNSEnabled          #   =   true
            DNSOverrideAllowed  #   =   false
            DNSServers          #   =   DNS Server(s) obtained from WAN DHCP server
            MaxMTUSize          #   =   1500
            MACAddress          #   =   MAC Address associated with the WAN interface
            MACAddressOverride  #   =   false
        )

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

    InternetGatewayDevice.WANDevice.i.WANDSLInterfaceConfig.TestParams.(){
        stats=(
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

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.i.WANConnectionDevice.i.WANDSLLinkConfig.(){
        stats=(
            Enable                  #=ture
            LinkStatus              #=Up
            LinkType                #=EoA
            AutoConfig              #=false
            ModulationType          #=Modulation associated with the connection, for example ADSL_2plus
            DestinationAddress      #=value of VPI/VCI associated with the connection
            ATMEncapsulation        #=Encapsulation associated with the connection (LLC or VC-MUX)
            ATMAAL                  #=AAL5
            ATMTransmittedBlocks    #=Value of transmitted cells
            ATMReceiveBlocks        #=Value of received cells
            ATMQoS                  #=QoS type being used on VC, for example UBR, CBR...
            AAL5CRCErrors           #=Count of the AAL5 layer cyclic redundancy check errors.
            ATMCRCErrors            #=Count of the ATM layer cyclic redundancy check (CRC) errors.
            ATMHECErrors            #=Count of the number of Header Error Check related errors at the ATM layer.
            ATMPeakCellRate         #=Value that specifies the upstream peak cell rate in cells per second.
            ATMMaximumBurstSize     #=value that specifies the upstream maximum burst size in cells.
            ATMSustainableCellRate  #=value that specifies the upstream sustainable cell rate, in cells per second, used for traffic shaping.
        )

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

    InternetGatewayDevice.WANDevice.i.WANDSLDiagnostics.(){
        stats=(
            ACTPSDds
            ACTPSDus
            ACTATPds
            ACTATPus
            HLINSCds
            HLINSCus
            HLINGds
            HLINGus
            HLOGGds
            HLOGGus
            HLOGpsds
            HLOGpsus
            HLOGMTds
            HLOGMTus
            LATNpbds
            SATNds
            SATNus
            HLINpsds
            HLINpsus
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
            BITSpsds
            BITSpsus
        )

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi
    }

    InternetGatewayDevice.WANDevice.i.WANEthernetInterfaceConfig.Stats.(){
        echo "in function InternetGatewayDevice.WANDevice.i.WANEthernetInterfaceConfig.Stats."

        stats=(
            BytesSent
            BytesReceived
            PacketsSent
            PacketsReceived
             )

        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            #echo "curr stat : ${stats[stats_index]}"
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv

            rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "$U_TR069_WANDEVICE_INDEX.WANEthernetInterfaceConfig.Stats.${stats[stats_index]}" |
                            awk -F= '{print $2}'`
            rule_value=`echo $current_rule | sed "s/U_GPV/U_CLI/g"`
            echo "export $rule_value=$rule_cli"
            export $rule_value=$rule_cli
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi

    }

   InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.Stats.(){
        echo "in function InternetGatewayDevice.LANDevice.i.WLANConfiguration.i.Stats."

        stats=(
        ErrorsSent
        ErrorsReceived
        UnicastPacketsSent
        UnicastPacketsReceived
        DiscardPacketsSent
        DiscardPacketsReceived
        MulticastPacketsSent
        MulticastPacketsReceived
#        BroadcastPacketsSent
#        BroadcastPacketsReceived
#        UnknownProtoPacketsReceived
        )

        bash $U_PATH_TBIN/cli_dut.sh -v wan.stats -o $G_CURRENTLOG/cli_dut_wan_stats.log

        for ((stats_index=0;stats_index<${#stats[@]};stats_index++));
        do
            #echo "curr stat : ${stats[stats_index]}"
            current_rule=$rule${stats[stats_index]}

            gpv_node="$curr_node2ser${stats[stats_index]}"
            echo "grep $gpv_node $logpath/$dst |awk -F = '{print $2}'"

            rule_gpv=`grep "$gpv_node" $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

            echo "rule_gpv is $rule_gpv"

            stats_rule=$stats_rule" -r \$"$current_rule

            echo "export $current_rule=$rule_gpv"

            export $current_rule=$rule_gpv

            rule_cli=`cat $G_CURRENTLOG/cli_dut_wan_stats.log |
                            grep "InternetGatewayDevice.LANDevice.$U_TR069_CUSTOM_LANDEVICE_INDEX.WLANConfiguration.$U_TR069_CUSTOM_SSID_NUMBER_1.Stats.${stats[stats_index]}" | awk -F= '{print $2}'`
            rule_value=`echo $current_rule | sed "s/U_GPV/U_CLI/g"`
            echo "export $rule_value=$rule_cli"
            export $rule_value=$rule_cli
        done

        echo "python $U_PATH_TBIN/custom_compare.py $stats_rule -i $rule_index -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
        python $U_PATH_TBIN/custom_compare.py $stats_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

        compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

        if [ "$compare_rc" == "TRUE" ] ;then
            echo "custom_compare.py passed !"
        elif [ "$compare_rc" == "FALSE" ] ;then
            echo "custom_compare.py failed !"
            let "result=$result+1"
        else
            echo "what happened: $compare_rc"
            let "result=$result+1"
        fi
  }

  InternetGatewayDevice.Firewall.LastChange(){
        echo "in GPV2 : curr_node2ser -> $curr_node2ser"

        rule_gpv=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/ //g"`

        date_gpvq=`echo $rule_gpv|grep -o "[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}"`

        date_gpv[0]=`echo "$date_gpvq"|awk -F -  '{print $1*1440*365}'`
        date_gpv[1]=`echo "$date_gpvq"|awk -F -  '{print $2*1440*30}'`
        date_gpv[2]=`echo "$date_gpvq"|awk -F -  '{print $3*1440}'`

        time_gpvq=`echo $rule_gpv|grep -o "[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}"`
        time_gpv[0]=`echo "$time_gpvq"|awk -F : '{print $1*60}'`
        time_gpv[1]=`echo "$time_gpvq"|awk -F : '{print $2}'`

        rule_gpv=` expr ${date_gpv[0]} + ${date_gpv[1]} + ${date_gpv[2]} + ${time_gpv[0]} + ${time_gpv[1]} `

        final_rule=$final_rule" -r \$"$rule

        echo "now the rule to pass to python is $final_rule"

        export $rule=$rule_gpv

        dst2=$dst"_1"

        rule_gpv2=`grep "$curr_node2ser " $logpath/$dst2 |awk -F = '{print $2}'|sed "s/ //g"`

        date_gpvq=`echo $rule_gpv2|grep -o "[0-9]\{4\}\-[0-9]\{2\}\-[0-9]\{2\}"`

        date_gpv[0]=`echo "$date_gpvq"|awk -F -  '{print $1*1440*365}'`
        date_gpv[1]=`echo "$date_gpvq"|awk -F -  '{print $2*1440*30}'`
        date_gpv[2]=`echo "$date_gpvq"|awk -F -  '{print $3*1440}'`

        time_gpvq=`echo $rule_gpv2|grep -o "[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}"`
        time_gpv[0]=`echo "$time_gpvq"|awk -F : '{print $1*60}'`
        time_gpv[1]=`echo "$time_gpvq"|awk -F : '{print $2}'`

        rule_gpv2=` expr ${date_gpv[0]} + ${date_gpv[1]} + ${date_gpv[2]} + ${time_gpv[0]} + ${time_gpv[1]} `

        rule_value="U_GPV2_"$current_case"_"$current_node

        export $rule_value=$rule_gpv2


  }




    method=`echo $curr_node2ser |sed "s/\.[0-9]\{1,\}/\.i/g" |sed "s/$U_TR069_CUSTOM_MANUFACTUREROUI/ACTIONTEC/g"`

    echo "method : $method"
    $method

    rc_cmd=$?

    if [ $rc_cmd -gt 0 ] ;then
        let "result=$result+1"
    fi

}

check_GPV(){
    echo "now , let's do the job ..."

    echo "python $U_PATH_TBIN/custom_compare.py $final_rule -f $U_CUSTOM_TR_RULE_FILE -o $G_CURRENTLOG/$currlogfilename"
    python $U_PATH_TBIN/custom_compare.py $final_rule '-i' $rule_index '-f' $U_CUSTOM_TR_RULE_FILE '-o' $G_CURRENTLOG/$currlogfilename

    check_gpv_rc=$?

    if [ $check_gpv_rc -gt 0 ] ;then
        echo "executing python failed !"
        let "result=$result+1"
    fi

    compare_rc=`cat $G_CURRENTLOG/$currlogfilename | head -1`

    if [ "$compare_rc" == "TRUE" ] ;then
        echo "custom_compare.py passed !"

        #~ for((z=0;z<${#node2ser[@]};z++)); do
            #~ to_append=${node2ser[z]}
            #~ echo "current node $z :$to_append" >> $G_CURRENTLOG/$currlogfilename
        #~ done

        result=0
    elif [ "$compare_rc" == "FALSE" ] ;then
        echo "custom_compare.py failed !"

        #~ for((z=0;z<${#node2ser[@]};z++)); do
            #~ to_append=${node2ser[z]}
            #~ echo "current node $z :$to_append" >> $G_CURRENTLOG/$currlogfilename
        #~ done
        #echo "AT_ERROR(4) : Compare failed between GPV result() with expected ()"
        let "result=$result+1"
    elif [ "$compare_rc" == "NONE" ] ;then
        special
        rc=$?
        if [ $rc -ne 0 ] ;then
            echo "rule not found ! please add this rule in $U_CUSTOM_TR_RULE_FILE if needed!"

            #~ for((z=0;z<${#node2ser[@]};z++)); do
                #~ to_append=${node2ser[z]}
                #~ echo "current node $z :$to_append" >> $G_CURRENTLOG/$currlogfilename
            #~ done

            let "result=$result+1"
        fi
    else
        echo "expect TRUE | FALSE | NONE ,but get: \"$compare_rc\" "
        let "result=$result+1"
    fi

    echo -e "\n" >> $G_CURRENTLOG/$currlogfilename

    for((z=0;z<${#node2ser[@]};z++)); do
        to_append=${node2ser[z]}
        is_to_append_exist=`grep "$to_append " $logpath/$dst`
        if [ "$is_to_append_exist" != "" ] ;then
            to_append_value=`grep "$to_append " $logpath/$dst |awk -F = '{print $2}'|sed "s/^ //g"`
        else
            to_append_value="empty_in_GPV"
        fi
        echo "node $z :$to_append   =   $to_append_value" >> $G_CURRENTLOG/$currlogfilename
    done
}

switch(){
    cecho debug "entering switch"
    echo "G_CURRENTLOG:$G_CURRENTLOG"
    base_name=`basename $G_CURRENTLOG`
    echo "base_name:$base_name"
    current_case=`echo $base_name |grep -o "B-GEN.*xml"| sed "s/[\.\-]/\_/g" |sed "s/B_GEN_TR98_//g"|sed "s/_xml//g"`

    echo "current case $current_case"

    for((i=0;i<${#node2ser[@]};i++)); do
        curr_node2ser=${node2ser[i]}

        echo "in switch : curr_node2ser -> $curr_node2ser"

        current_node=`echo $curr_node2ser |sed "s/\.[0-9]\{1,\}/\.i/g" | sed "s/[\.\-]/\_/g"`
        echo "current_node:$current_node"
        rule="U_GPV_"$current_case"_"$current_node
        echo "rule:$rule"
        if [ $rule_index -eq 1 ] ;then
            is_cli=`grep "$rule " $U_CUSTOM_TR_RULE_FILE | awk '{print $3}' | grep -o 'U_CLI' | head -1`
        elif [ $rule_index -gt 1 ] ;then
            is_cli=`grep "$rule " $U_CUSTOM_TR_RULE_FILE | awk '{print $3}' | grep -o 'U_CLI' | head -$rule_index | tail -1`
        fi

        if [ $rule_index -eq 1 ] ;then
            is_gpv2=`grep "$rule " $U_CUSTOM_TR_RULE_FILE | awk '{print $3}' | grep -o 'GPV2' | head -1`
        elif [ $rule_index -gt 1 ] ;then
            is_gpv2=`grep "$rule " $U_CUSTOM_TR_RULE_FILE | awk '{print $3}' | grep -o 'GPV2' | head -$rule_index | tail -1`
        fi

        is_rule_gpv_exist=`grep "$curr_node2ser " $logpath/$dst`

        is_rule_gpv_exist_value=`grep "$curr_node2ser " $logpath/$dst |awk -F = '{print $2}'|sed "s/^ //g"`

        if [ "$is_rule_gpv_exist" == "" ] ;then
            echo "node not found : $curr_node2ser !" |tee -a $G_CURRENTLOG/$out_detail
            echo "AT_ERROR(2) : Parameter($curr_node2ser) is not found in GPV file"
        else
            if [ "$is_rule_gpv_exist_value" == "" ] ;then
                echo "node value empty : $curr_node2ser !" |tee -a $G_CURRENTLOG/$out_detail
                echo "AT_ERROR(3): Parameter($curr_node2ser) is found but value is empty in GPV file"
            else
                echo "node : $curr_node2ser = $is_rule_gpv_exist_value" |tee -a $G_CURRENTLOG/$out_detail
            fi
        fi

        echo "-- to process Rules..."

        if [ "U_CLI" == "$is_cli" ] ;then
            echo "let me do the cli first !"
            needCLI
        elif [ "GPV2" == "$is_gpv2" ] ;then
            echo "need to compare two gpv result !"
            GPV2
        else
            echo "I'll do the job directly !"
            common
        fi
    done

    check_GPV

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


node2ser=(
)

nodes_idx=0

final_rule=""

out="custom_compare.log"

flag=0

rule_index=1

result=0

while [ -n "$1" ];
do
    case "$1" in
        -node)
            node2ser[nodes_idx]=$2
            echo "the node to be searched in GPV log is ${node2ser[nodes_idx]}"
            let "nodes_idx=$nodes_idx+1"
            shift 2
            ;;
        -i)
            rule_index=$2
            echo "the rule_index is ${rule_index}"
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

if [ -f "$U_CUSTOM_TR_RULE_FILE" ] ;then
    echo "rule file : $U_CUSTOM_TR_RULE_FILE"
else
    echo "AT_ERROR(1) : Custom Compare Rule file not found : $U_CUSTOM_TR_RULE_FILE"
    exit 1
fi

if [ ! -f "$logpath/$dst" ] ;then
    echo "AT_ERROR(1) : GPV result file :$dst cannot be located , not found"
    exit 1
fi

echo "==To create log file "
createlogname $out
cecho debug "current logfile name is : "$currlogfilename

out_detail=${currlogfilename}".detail"

switch

#detailedLog

cecho debug "the final result is ${result}"

echo -e "\n" |tee -a $G_CURRENTLOG/$currlogfilename
echo "--------------------------- detailed nodes info ---------------------------" |tee -a $G_CURRENTLOG/$currlogfilename

cat $G_CURRENTLOG/$out_detail |tee -a $G_CURRENTLOG/$currlogfilename


if [ $flag -eq 0 ] ;then
    cecho debug "positive test "
    if [ $result -eq 0 ] ;then
        cecho debug "positive test : result -- PASS"
        #exit 0
    else
        cecho debug "positive test : result -- FAIL"
        echo error "AT_ERROR : " `cat $G_CURRENTLOG/$currlogfilename | grep -e "^False" -e "^NONE"`
        #exit 0
    fi
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
