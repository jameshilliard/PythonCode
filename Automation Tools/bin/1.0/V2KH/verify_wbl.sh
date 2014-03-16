#!/bin/bash
usage="verify_wbl.sh -n -f <file name>"

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
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}
Q1K()
{
    if [  $flag -ne 0 ] ;then
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}
SV1KH()
{
    if [  $flag -ne 0 ] ;then
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}

FGT784WN()
{
    if [  $flag -ne 0 ] ;then
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}

TV2KH()
{
    if [  $flag -ne 0 ] ;then
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}
TV1KF()
{
    if [  $flag -ne 0 ] ;then
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'false'
    else
        bash $U_PATH_TBIN/verifyFile.sh  $filename 'true'
    fi
}
$U_DUT_TYPE
