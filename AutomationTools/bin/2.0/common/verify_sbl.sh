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

USAGE()
{
    cat <<usge
USAGE : bash $0 [-test] -s <bltype> -n | -y  <site address>

OPTIONS:

      -test:    test mode,set all the global variables if it is not run in testcase
      -s:       service block type,ftp http website and so on
      -n:       service not blocked
      -y:       service blocked
      -i:       interface

NOTE : if you DON'T run this script in testcase , please put [-test] option in front of all the other options

EXAMPLES:   bash $0 -test -s ftp -i eth2 -n 192.168.10.241 -s http -i eth1 -n www.google.com -y www.baidu.com -s website -i eth1 -n www.google.com
usge
}

special_type=(TV2KH BHR4_OpenWRT BHR2 TDSV2200H BAR1KH BCV1200)
#TV2KH -- 31.122L.01

special_fw=()

dtype=common

ftype=common

U_CUSTOM_CURL_TIMEOUT=${U_CUSTOM_CURL_TIMEOUT:-30}

result=0

change_route(){
    if [ "$def_interface" == "$G_HOST_IF0_1_0"  ] ;then
        ip_addr=$G_HOST_TIP0_1_0
    elif [ "$def_interface" == "$G_HOST_IF0_2_0"  ] ;then
        ip_addr=$G_HOST_TIP0_2_0
    fi

    bash $U_PATH_TBIN/verifyDutLanConnected.sh -i $def_interface -a $ip_addr

    sw_rc=$?

    if [ $sw_rc -gt 0 ] ;then
        echo "AT_ERROR : error change default route !"
        exit 1
    #else
    fi
    }

verifyFile(){
    if [ -f "$1" ]; then
        if [ $flag -eq 1 ]; then
            echo -e " verifyFile PASSED ";
        else
            echo -e " verifyFile FAILED ";
            let "result=$result+1"
        fi
    else
        if [ $flag -eq 0 ]; then
            echo -e " verifyFile PASSED ";
        else
            echo -e " verifyFile FAILED ";
            let "result=$result+1"
        fi
    fi
}

createlogname(){
    lognamex=$1
    lognamex=`echo ${lognamex}|sed "s/\//_/g"`
    echo "ls $G_CURRENTLOG/$lognamex*"
    ls $G_CURRENTLOG/$lognamex* 2> /dev/null
    if [  $? -gt 0 ]; then
        #echo "file not exists"
        echo -e " so the current file to be created is : "$lognamex"1"
        currlogfilename=$lognamex"1"
    else
        #echo "file exists"
        curr=`ls $G_CURRENTLOG/$lognamex*|wc -l`
        let "next=$curr+1"
        echo -e " so the current file to be created is : "$lognamex$next""
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
        #let "result=$result+$?"
        echo -e " the result now is : $result "
    elif [ $dtype == $U_DUT_TYPE ]; then
        echo "entering switch : special"
        special
        #let "result=$result+$?"
        echo -e " the result now is : $result "
    fi
}

common(){
    website(){
        echo "entering common -> website..."

        #echo "  going to start httpd on WAN PC"

        #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_start_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd restart" -d $G_HOST_IP1

        #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_start_httpd.log

        #start_httpd_rc=$?

        #if [ $start_httpd_rc -gt 0 ] ;then
        #    echo "AT_ERROR : starting httpd FAILED !"
        #    exit 1
        #fi

        if [ $flag -ne 0 ]; then
            createlogname wbl-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            perl $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/$currlogfilename
        else
            createlogname wbl-$filename-block.log
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            perl $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'   -f $G_CURRENTLOG/$currlogfilename
        fi

        rc_wbl=$?

        if [ "$rc_wbl" -gt 0 ] ;then
            echo "AT_ERROR : verify website blocking on $filename FAILED !"

            echo "result=$result+$rc_wbl"
            let "result=$result+$rc_wbl"
        else
            echo "AT_INFO : verify website blocking on $filename PASSED !"
        fi

        #echo "  going to shutdown httpd on WAN PC"

        #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_stop_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd stop" -d $G_HOST_IP1

        #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_stop_httpd.log

        #stop_httpd_rc=$?

        #if [ $stop_httpd_rc -gt 0 ] ;then
        #    echo "AT_ERROR : stopping httpd FAILED !"
        #    exit 1
        #fi

        }

    ftp(){
            echo "entering common -> ftp ..."
            if [ $flag -ne 0 ]; then
                createlogname ftp-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify ftp unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify ftp unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname ftp-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify ftp block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify ftp block on $filename PASSED! "
                fi
            fi
        }

    http(){
        echo "entering function common -> http..."

        if [  $flag -ne 0 ]; then
            createlogname http-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!' -f $G_CURRENTLOG/$currlogfilename
        else
            createlogname http-$filename-block.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/$currlogfilename
        fi

        rc_http=$?

        if [ "$rc_http" -gt 0 ] ;then
            echo "AT_ERROR : verify HTTP blocking on $filename FAILED !"

            echo "result=$result+$rc_http"
            let "result=$result+$rc_http"
        else
            echo "AT_INFO : verify HTTP blocking on $filename PASSED !"
        fi
    }
    $sbltype
}

special(){
    echo "entering function special..."
    BHR4_OpenWRT:common(){
        website(){
         echo "entering special -> BHR4_OpenWRT:common -> website..."

        #echo "  going to start httpd on WAN PC"

        #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_start_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd restart" -d $G_HOST_IP1

        #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_start_httpd.log

        #start_httpd_rc=$?

        #if [ $start_httpd_rc -gt 0 ] ;then
        #    echo "AT_ERROR : starting httpd FAILED !"
        #    exit 1
        #fi

        if [ $flag -ne 0 ]; then
            createlogname wbl-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            #perl $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/$currlogfilename
            rc_wbl=$?
        else
            createlogname wbl-$filename-block.log
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
           # perl $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'   -f $G_CURRENTLOG/$currlogfilename
            rc_wbl=$?
        fi

        #rc_wbl=$?

        if [ "$rc_wbl" -gt 0 ] ;then
            #echo "AT_ERROR : verify website blocking on $filename FAILED !"

            #echo "result=$result+$rc_wbl"
            #let "result=$result+$rc_wbl"
        #else
            echo "AT_INFO : verify website blocking on PASSED !"
        fi

        #echo "  going to shutdown httpd on WAN PC"

        #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_stop_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd stop" -d $G_HOST_IP1

        #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_stop_httpd.log

        #stop_httpd_rc=$?

        #if [ $stop_httpd_rc -gt 0 ] ;then
        #    echo "AT_ERROR : stopping httpd FAILED !"
        #    exit 1
        #fi
         }
    ftp(){
            echo "entering BHR4_OpenWRT:common -> ftp ..."
            if [ $flag -ne 0 ]; then
                createlogname ftp-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify ftp unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify ftp unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname ftp-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                perl $U_PATH_TBIN/verifyFTP.pl -o $currlogfilename -l $G_CURRENTLOG -d $filename -u $U_CUSTOM_FTP_USR -p $U_CUSTOM_FTP_PSW -t 20
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify ftp block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify ftp block on $filename PASSED! "
                fi
            fi
        }

    http(){
        echo "entering function BHR4_OpenWRT:common -> http..."

        if [  $flag -ne 0 ]; then
            createlogname http-$filename-unblock.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
            #perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!' -f $G_CURRENTLOG/$currlogfilename
            rc_http=$?
        else
            createlogname http-$filename-block.log
            echo "current logfile name is : "$currlogfilename
            echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
            curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
           # perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/$currlogfilename
            rc_http=$?
        fi

        #rc_http=$?

        if [ "$rc_http" -gt 0 ] ;then
            #echo "AT_ERROR : verify HTTP blocking on $filename FAILED !"

            #echo "result=$result+$rc_http"
            #let "result=$result+$rc_http"
        #else
            echo "AT_INFO : verify HTTP blocking on PASSED !"
        fi
    }
    $sbltype
}
    TV2KH:common()
    {
        website(){
            echo "entering special -> TV2KH:common -> website..."

            #echo "  going to start httpd on WAN PC"

            #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_start_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd restart" -d $G_HOST_IP1

            #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_start_httpd.log

            #start_httpd_rc=$?

            #if [ $start_httpd_rc -gt 0 ] ;then
            #    echo "AT_ERROR : starting httpd FAILED !"
            #    exit 1
            #fi

            if [  $flag -ne 0 ]; then
                createlogname wbl-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify website unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify website unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname wbl-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify http block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify http block on $filename PASSED! "
                fi
            fi

            #echo "  going to shutdown httpd on WAN PC"

            #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_stop_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd stop" -d $G_HOST_IP1

            #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_stop_httpd.log

            #stop_httpd_rc=$?

            #if [ $stop_httpd_rc -gt 0 ] ;then
            #    echo "AT_ERROR : stopping httpd FAILED !"
            #    exit 1
            #fi
        }

        ftp(){
            echo "entering special -> TV2KH:common -> ftp..."
            common
        }

        http(){
            echo "entering special -> TV2KH:common -> http..."

            if [  $flag -ne 0 ]; then
                createlogname http-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Invalid user name and password' -e "Nom d\’utilisateur ou mot de passe non valide"  -f $G_CURRENTLOG/$currlogfilename
            else
                createlogname http-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Invalid user name and password' -e "Nom d\’utilisateur ou mot de passe non valide"  -f $G_CURRENTLOG/$currlogfilename
            fi

            rc_http=$?

            if [ "$rc_http" -gt 0 ] ;then
                echo "AT_ERROR : verify HTTP blocking on $filename FAILED !"

                echo "result=$result+$rc_http"
                let "result=$result+$rc_http"
            else
                echo "AT_INFO : verify HTTP blocking on $filename PASSED !"
            fi
        }
        $sbltype
    }

    TDSV2200H:common()
    {
        website(){
            echo "entering special -> TDSV2200H:common -> website..."

            if [  $flag -ne 0 ]; then
                createlogname wbl-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify website unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify website unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname wbl-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify http block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify http block on $filename PASSED! "
                fi
            fi
        }

        ftp(){
            echo "entering special -> TDSV2200H:common -> ftp..."
            common
        }

        http(){
            echo "entering special -> TDSV2200H:common -> http..."

            if [  $flag -ne 0 ]; then
                createlogname http-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Diagnostics - Login Required' '-e' 'Diagnostic - ouverture de session requise' -f $G_CURRENTLOG/$currlogfilename
            else
                createlogname http-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Diagnostics - Login Required' '-e' 'Diagnostic - ouverture de session requise' -f $G_CURRENTLOG/$currlogfilename
            fi

            rc_http=$?

            if [ "$rc_http" -gt 0 ] ;then
                echo "AT_ERROR : verify HTTP blocking on $filename FAILED !"

                echo "result=$result+$rc_http"
                let "result=$result+$rc_http"
            else
                echo "AT_INFO : verify HTTP blocking on $filename PASSED !"
            fi
        }
        $sbltype
    }

    BCV1200:common()
    {
        TV2KH:common
    }


    BAR1KH:common()
    {
        website(){
            echo "entering special -> BAR1KH:common -> website..."


            if [  $flag -ne 0 ]; then
                createlogname wbl-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify website unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify website unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname wbl-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify http block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify http block on $filename PASSED! "
                fi
            fi

        }

        ftp(){
            echo "entering special -> BAR1KH:common -> ftp..."
            common
        }

        http(){
            echo "entering special -> BAR1KH:common -> http..."
            website
        }
        $sbltype
    }
    
    BHR2:common()
    {
        website(){
            echo "entering special -> BHR2:common -> website..."

            #echo "  going to start httpd on WAN PC"

            #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_start_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd restart" -d $G_HOST_IP1

            #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_start_httpd.log

            #start_httpd_rc=$?

            #if [ $start_httpd_rc -gt 0 ] ;then
            #    echo "AT_ERROR : starting httpd FAILED !"
            #    exit 1
            #fi

            if [ $flag -ne 0 ]; then
                createlogname wbl-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl $U_PATH_TBIN/searchoperation.pl '-n' '-e' "Page(1390)=\[Blocked Access\]"  -f $G_CURRENTLOG/$currlogfilename
            else
                createlogname wbl-$filename-block.log
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                perl $U_PATH_TBIN/searchoperation.pl '-e' "Page(1390)=\[Blocked Access\]"   -f $G_CURRENTLOG/$currlogfilename
            fi

            rc_wbl=$?

            if [ "$rc_wbl" -gt 0 ] ;then
                echo "AT_ERROR : verify website blocking on $filename FAILED !"

                echo "result=$result+$rc_wbl"
                let "result=$result+$rc_wbl"
            else
                echo "AT_INFO : verify website blocking on $filename PASSED !"
            fi

            #echo "  going to shutdown httpd on WAN PC"

            #perl $U_PATH_TBIN/sshcli.pl -o $G_CURRENTLOG/sshcli_stop_httpd.log -l $G_CURRENTLOG -u $G_HOST_USR1 -p $G_HOST_PWD1 -v "service httpd stop" -d $G_HOST_IP1

            #perl $U_PATH_TBIN/searchoperation.pl '-e' '[  OK  ]'   -f $G_CURRENTLOG/sshcli_stop_httpd.log

            #stop_httpd_rc=$?

            #if [ $stop_httpd_rc -gt 0 ] ;then
            #    echo "AT_ERROR : stopping httpd FAILED !"
            #    exit 1
            #fi
        }

        ftp(){
            echo "entering special -> TV2KH:common -> ftp..."
            common
        }
        http(){
            echo "entering special -> TV2KH:common -> http..."

            if [  $flag -ne 0 ]; then
                createlogname http-$filename-unblock.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_INFO : verify http unblock on $filename PASSED! "
                else
                    echo -e " AT_ERROR : verify http unblock on $filename FAILED! "
                    let "result=$result+1"
                fi
            else
                createlogname http-$filename-block.log
                echo "current logfile name is : "$currlogfilename
                echo "curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v"
                curl -L $filename -o $G_CURRENTLOG/$currlogfilename -m $U_CUSTOM_CURL_TIMEOUT -v
                if [ $? -eq 0 ]; then
                    echo -e " AT_ERROR : verify http block on $filename FAILED! "
                    let "result=$result+1"
                else
                    echo -e " AT_INFO : verify http block on $filename PASSED! "
                fi
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
    -i)
        def_interface=$2

        change_route

        shift 2
        ;;
    -y)
        flag=0
        echo -e "flag : ${flag}"" blocked"
        filename=$2

        if [ -z $filename ] ;then
            echo "AT_ERROR : the dest ip must be initialed !"
            exit 1
        fi

        echo -e "site name :  ${filename}"

        switch

        shift 2
        ;;
    -n)
        flag=1
        echo -e "flag : ${flag}"" not blocked"
        filename=$2
        echo -e "site name :  ${filename}"

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
        USAGE
        exit 1
        ;;
    esac
done
echo -e " the final result is : $result  "

def_interface=$G_HOST_IF0_1_0

change_route
if [ $result -gt 0 ];then
    echo "cat /etc/resolv.conf"
    cat /etc/resolv.conf
    echo "nslookup $filename"
    nslookup $filename
	echo "ping $G_PROD_IP_BR0_0_0 -c 10"
    ping $G_PROD_IP_BR0_0_0 -c 10
    echo "ping $TMP_DUT_DEF_GW -c 10"
    ping $TMP_DUT_DEF_GW -c 10
    bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/cli_dut_wan_info.log
    bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/cli_dut_wan_dns.log
	echo "curl -L www.vosky.com"
	curl -L www.vosky.com
	$U_AUTO_CONF_BIN $U_DUT_TYPE $G_SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Security/firewall/B-GEN-SEC.FW-001-D001 $U_AUTO_CONF_PARAM -l $G_CURRENTLOG/GUI-CHECK-WAN
    $U_PATH_TBIN/clicmd -o ${G_CURRENTLOG}/wan_named.log -u $G_HOST_USR1 -p $G_HOST_PWD1 -d $G_HOST_IP1 -v "service named status" -v "service named restart"
    echo "curl -L $filename"
    curl -L $filename
    echo "nslookup $filename"
    nslookup $filename
fi
exit $result
