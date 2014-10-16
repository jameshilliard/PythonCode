#!bin/bash

usage="getDataFromCLI.sh -d <ip address> -u <username> -p <password> -v <command> -l <log dir> -o <output file>"

dir=./

while [ -n "$1" ];
do
    case "$1" in
    -d)
        ipaddr=$2
        shift 2
        ;;

    -u)
        username=$2
        shift 2
        ;;

    -p)
        password=$2
        shift 2
        ;;

    -v)
        command=$2
        echo "execute command : ${command}"

        shift 2
        ;;    

    -l)
        dir=$2
        shift 2
        ;;    

    -o)
        outputfile=$2
        echo "outputfile name : ${outputfile}"

        shift 2
        ;;
    
    *)
        echo $usage
        exit 1
        ;;
    esac
done

cecho() {
    case $1 in
        black_fore)
            echo -e "\033[30m $2 \033[0m"
            ;;
        red_fore)
            echo -e "\033[31m $2 \033[0m"
            ;;
        green_fore)
            echo -e "\033[32m $2 \033[0m"
            ;;
        blown_fore)
            echo -e "\033[33m $2 \033[0m"
            ;;
        blue_fore)
            echo -e "\033[34m $2 \033[0m"
            ;;
        purple_fore)
            echo -e "\033[35m $2 \033[0m"
            ;;
        black_back)
            echo -e "\033[40m $2 \033[0m"
            ;;
        red_back)
            echo -e "\033[41m $2 \033[0m"
            ;;
        green_back)
            echo -e "\033[42m $2 \033[0m"
            ;;
        blown_back)
            echo -e "\033[43m $2 \033[0m"
            ;;
        blue_back)
            echo -e "\033[44m $2 \033[0m"
            ;;
        purple_back)
            echo -e "\033[45m $2 \033[0m"
            ;;
        blue_red)
            echo -e "\033[42;31m $2 \033[0m"
    esac
}
echo "perl $SQAROOT/bin/$G_BINVERSION/common/DUTCmd.pl -d $ipaddr -u $username -p $password -v "$command" -l $dir -o $outputfile"
perl $SQAROOT/bin/$G_BINVERSION/common/DUTCmd.pl -d $ipaddr -u $username -p $password -v "$command" -l $dir -o $outputfile 

if [ $? -eq 0 ]; then
    UpstreamMaxRate=`grep "Max:" $dir/$outputfile |awk -F, '{print $1}'|awk -F= '{print $2}'|sed 's/ *Kbps *//g'`
    if [ -n "$UpstreamMaxRate" ]; then
        echo "Layer1UpstreamMaxBitRate = $UpstreamMaxRate">$dir/temp.log
    fi

    DownstreamMaxRate=`grep "Max:" $dir/$outputfile |awk -F, '{print $2}'|awk -F= '{print $2}'|sed 's/ *Kbps *//g'`
    if [ -n "$DownstreamMaxRate" ]; then
        echo "Layer1DownstreamMaxBitRate = $DownstreamMaxRate">>$dir/temp.log
    fi

    TotalBytesSent=`grep "ptm0.1:" $dir/$outputfile |awk -F ' ' '{print $2}'`
    if [ -n "$TotalBytesSent" ]; then
        echo "TotalBytesSent = $TotalBytesSent">$dir/temp.log
    fi

    TotalBytesReceived=`grep "ptm0.1:" $dir/$outputfile |awk -F ' ' '{print $10}'`
    if [ -n "$TotalBytesReceived" ]; then
        echo "TotalBytesReceived = $TotalBytesReceived">>$dir/temp.log
    fi

    TotalPacketsSent=`grep "ptm0.1:" $dir/$outputfile |awk -F ' ' '{print $3}'`
    if [ -n "$TotalPacketsSent" ]; then
        echo "TotalPacketsSent = $TotalPacketsSent">>$dir/temp.log
    fi

    TotalPacketsReceived=`grep "ptm0.1:" $dir/$outputfile |awk -F ' ' '{print $11}'`
    if [ -n "$TotalPacketsReceived" ]; then
        echo "TotalPacketsReceived = $TotalPacketsReceived">>$dir/temp.log
    fi

    mv -f $dir/temp.log $dir/$outputfile

    cecho green_fore "pass to getDataFromCLI.sh"
    exit 0

else
    cecho red_back "getDataFromCLI.sh fail!"
    exit 1
fi
