#!/bin/bash
######################################################################################
# Author : Howard Yin                                                                #
# Date : 7-28-2011                                                                   #   
# Description : this script is used to verify different kinds of service block       #
# Usage : bash verify_sbl_test.sh -test -s ftp -n 192.168.10.241 -s http \           #
#         -n www.google.com -s http -y www.baidu.com -s website -y www.google.com    #
# Param : -s stands for service block type (ftp  http),-n stands for not blocked,    #
#         -y stands for blocked ,if failed,this script will return a non-zero value  #
######################################################################################
usage="usage : bash $0 \033[33m [-test]\033[0m -s <bltype> -n | -y  <site address>  \n -test:\ttest mode,set all the global variables if it is not run in testcase\n -s:\tservice block type,ftp http website and so on\n -n:\tservice not blocked\n -y:\tservice blocked\n eg:\tbash $0 -test -s ftp -n 192.168.10.241 -s http -n www.google.com -y www.baidu.com"

USAGE()
{
    cat <<usge
USAGE : bash $0 [-test] -s <bltype> -n | -y  <site address>  

OPTIONS:

	  -test:    test mode,set all the global variables if it is not run in testcase
	  -s:       service block type,ftp http website and so on
	  -n:       service not blocked
	  -y:       service blocked

NOTE : if you DON'T run this script in testcase , please put [-test] option in front of all the other options

EXAMPLES:   bash $0 -test -s ftp -n 192.168.10.241 -s http -n www.google.com -y www.baidu.com 
usge
}

special_type=(TV2KH SV1KH)

special_fw=(31.60L.14)

dtype=common

ftype=common

result=0

verifyFile(){
    if [ -f "$1" ]; then
        if [ $flag -eq 1 ]; then
            echo -e "\033[33m verifyFile PASSED \033[0m";
        else
            echo -e "\033[33m verifyFile FAILED \033[0m";
            let "result=$result+1"
        fi
    else 
        if [ $flag -eq 0 ]; then
            echo -e "\033[33m verifyFile PASSED \033[0m";
        else
            echo -e "\033[33m verifyFile FAILED \033[0m";
            let "result=$result+1"
        fi
    fi
}

createlogname(){
    lognamex=$1
    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        echo "file not exists"
        echo -e "\033[33m so the current file to be created is : "$lognamex"1\033[0m"
        currlogfilename=$lognamex"1"
    else
        echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr+1"
        echo -e "\033[33m so the current file to be created is : "$lognamex$next"\033[0m"
        currlogfilename=$lognamex$next
    fi
}

switch(){
    echo "entering switch"
    for ((i=0;i<${#special_type[@]};i++)); do
        if [ ${special_type[i]} == $U_DUT_TYPE  ]; then
            dtype=$U_DUT_TYPE
        fi
    done

    for ((i=0;i<${#special_fw[@]};i++)); do
        if [ ${special_fw[i]} == $U_DUT_FW_VERSION  ]; then
            ftype=$U_DUT_FW_VERSION
        fi
    done
    echo "dtype="$dtype
    echo "ftype="$ftype

    if [ $dtype == "common" ]; then
        echo "entering switch : common"
        common
        let "result=$result+$?"
        echo -e "\033[33m the result now is : $result \033[0m"
    elif [ $dtype == $U_DUT_TYPE ]; then
        echo "entering switch : special"
        special
        let "result=$result+$?"
        echo -e "\033[33m the result now is : $result \033[0m"
    fi
}

common(){
    website(){
        echo "entering common -> website..."
        if [ $flag -ne 0 ]; then
            createlogname wbl-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
            verifyFile  $G_CURRENTLOG/$currlogfilename
        else
            createlogname wbl-$filename-block.log
            perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
            verifyFile  $G_CURRENTLOG/$currlogfilename
        fi
        }

    ftp(){
            echo "entering common -> ftp ..."
            if [ $flag -ne 0 ]; then
                createlogname ftp-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -eq 0 ]; then
                    echo -e "\033[33m verify ftp passed! \033[0m"
                else
                    echo -e "\033[33m verify ftp failed! \033[0m"
                    let "result=$result+1"
                fi
            else
                createlogname ftp-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -gt 0 ]; then
                    echo -e "\033[33m verify ftp passed! \033[0m"
                else
                    echo -e "\033[33m verify ftp failed! \033[0m"
                    let "result=$result+1"
                fi
            fi
        }

    http(){
        echo "entering function common -> http..."
    
        if [  $flag -ne 0 ]; then
            createlogname http-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
            perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!' -f $G_CURRENTLOG/$currlogfilename
        else
            createlogname http-$filename-block.log
            echo "current logfile name is : "$currlogfilename
            perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
            perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/$currlogfilename
        fi
    }
    $sbltype
}

special(){
    echo "entering function special..."
    
    TV2KH:31.60L.14()
    {
        website(){
            echo "entering special -> TV2KH:31.60L.14 -> website..."
            common
        }
        
        ftp(){
            echo "entering special -> TV2KH:31.60L.14 -> ftp..."
            common
        }
        http(){
            echo "entering special -> TV2KH:31.60L.14 -> http..."

            if [  $flag -ne 0 ]; then
                createlogname http-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Actiontec'  '-e' '404 Not Found' -f $G_CURRENTLOG/$currlogfilename
            else
                createlogname http-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Actiontec' '-e' '404 Not Found'  -f $G_CURRENTLOG/$currlogfilename
            fi
        }
        $sbltype
    }
    
    SV1KH:common()
    {
        website(){
            echo "entering special -> SV1KH:common -> website..."
            common
        }
        
        ftp(){
            echo "entering special -> SV1KH:common -> ftp..."
            common
        }

        http(){
            echo "entering special -> SV1KH:common -> http..."

            if [  $flag -ne 0 ]; then
                createlogname http-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'www.sasktel.com'  '-e' '404 Not Found' -f $G_CURRENTLOG/$currlogfilename
            else
                createlogname http-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyCurl.pl -d $filename -o $currlogfilename -l $G_CURRENTLOG -t 10
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'www.sasktel.com' '-e' '404 Not Found'  -f $G_CURRENTLOG/$currlogfilename
            fi
        }
    
        $sbltype
    }
    $dtype:$ftype
}

flag=0
while [ -n "$1" ];
do
    case "$1" in
    -s)
        sbltype=$2
        shift 2
        ;;
    -y)
        flag=0
        echo -e "flag : ${flag}""\033[33m blocked\033[0m"
        filename=$2
        echo -e "site name :\033[33m  ${filename}\033[0m"

        switch

        shift 2
        ;;
    -n)
        flag=1
        echo -e "flag : ${flag}""\033[33m not blocked\033[0m"
        filename=$2
        echo -e "site name :\033[33m  ${filename}\033[0m"

        switch

        shift 2
        ;;
    -test)
        U_PATH_TBIN=./
        G_CURRENTLOG=/tmp
        G_HOST_IF0_2_0=eth2
        U_DUT_TYPE=TV2KH
        U_DUT_FW_VERSION=31.60L.14
        U_CUSTOM_FTP_SITE=192.168.10.241
        U_CUSTOM_FTP_USR=actiontec
        U_CUSTOM_FTP_PSW=actiontec
        shift 1
        ;;
    -help)
        USAGE
        exit 1
        ;;
    *)
        echo -e $usage
        exit 1
        ;;
    esac
done
echo -e "\033[33m the final result is : $result \033[0m "
exit $result
