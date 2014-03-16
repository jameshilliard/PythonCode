#!/bin/bash
usage="comment_tst.sh -s <source effected config file list> -t <target tst file>"
while [ -n "$1" ];
do
    case "$1" in

    -s)
        src=$2
        echo "source effected config file list : ${src}"
        shift 2
        ;;
    -t)
        dst=$2
        echo "dest tst file : ${dst}"
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
for i in $src
do

done
exit 0
