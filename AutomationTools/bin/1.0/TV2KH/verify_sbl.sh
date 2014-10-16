#!/bin/bash
usage="verify_sbl_http.sh -s <bltype> -n | -y  <file name>"
special_type=(TV2KH SV1KH)

special_fw=(31.60L.14)

dtype=common

ftype=common

result=0

common(){
    http(){
        echo "entering function common -> http..."
    
        if [  $flag -ne 0 ] ;then
            tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-unblocked.log
            perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!' -f $G_CURRENTLOG/curl-$filename-unblocked.log
        else
            tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-blocked.log
            perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $G_CURRENTLOG/curl-$filename-blocked.log
        fi
    }
    $sbltype
}

special(){
    echo "entering function special..."
    
    TV2KH:31.60L.14()
    {
        http(){
            echo "entering special -> TV2KH:31.60L.14 -> http..."

            if [  $flag -ne 0 ] ;then
                tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-unblocked.log
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Actiontec'  '-e' '404 Not Found' -f $G_CURRENTLOG/curl-$filename-unblocked.log
            else
                tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-blocked.log
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Actiontec' '-e' '404 Not Found'  -f $G_CURRENTLOG/curl-$filename-blocked.log
            fi
        }
        $sbltype
    }
    
    SV1KH:common()
    {
        http(){
            echo "entering special -> SV1KH:common -> http..."
    
            if [  $flag -ne 0 ] ;then
                tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-unblocked.log
                perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'www.sasktel.com' -f $G_CURRENTLOG/curl-$filename-unblocked.log
            else
                tclsh $U_PATH_TBIN/verifyCurl.tcl $G_HOST_IF0_2_0 $filename $G_CURRENTLOG/curl-$filename-blocked.log
                perl  $U_PATH_TBIN/searchoperation.pl '-e' 'www.sasktel.com'  -f $G_CURRENTLOG/curl-$filename-blocked.log
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
        echo "flag : ${flag}"
        filename=$2
        echo "file name : ${filename}"

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
            echo "the result now is : $result"
        elif [ $dtype == $U_DUT_TYPE ]; then
            echo "entering switch : special"
            special
            let "result=$result+$?"
            echo "the result now is : $result"
        fi
        shift 2
        ;;
    -n)
        flag=1
        echo "flag : ${flag}"
        filename=$2
        echo "file name : ${filename}"

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
            echo "the result now is : $result"
        elif [ $dtype == $U_DUT_TYPE ]; then
            echo "entering switch : special"
            special
            let "result=$result+$?"
            echo "the result now is : $result"
        fi
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
echo "the final result is : $result"
exit $result
