#!/bin/bash
usage="verify_sbl_http.sh -n -f <file name>"

#Q2K
flag=0
while [ -n "$1" ];
do
    case "$1" in

    -f)
        filename=$2
        echo "file name : ${filename}"
        shift 2
        ;;
    -n)
        flag=1
        echo "flag : ${flag}"
        shift 1
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done

Q2K()
{
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!'  -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $filename
    fi
}
Q1K()
{
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!'  -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $filename
    fi
}

SV1KH()
{
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'www.sasktel.com'  -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'www.sasktel.com'  -f $filename
    fi
}
FGT784WN()
{
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'ACCESS DENIED!!'  -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'ACCESS DENIED!!'  -f $filename
    fi
}
TV2KH()
{
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Actiontec'  '-e' '404 Not Found' -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Actiontec' '-e' '404 Not Found'  -f $filename
    fi
}
TV1KF(){
    if [  $flag -ne 0 ] ;then
        perl  $U_PATH_TBIN/searchoperation.pl '-n' '-e' 'Actiontec'  '-e' '404 Not Found' -f $filename
    else
        perl  $U_PATH_TBIN/searchoperation.pl '-e' 'Actiontec' '-e' '404 Not Found'  -f $filename
    fi
}
$U_DUT_TYPE
