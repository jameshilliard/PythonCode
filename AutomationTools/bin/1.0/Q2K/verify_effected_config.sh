#!/bin/bash
usage="verify_effected_config.sh -s <source html list> -t <dest verify config folder> -o <output dir>"
while [ -n "$1" ];
do
    case "$1" in

    -s)
        src=$2
        echo "source html list file : ${src}"
        shift 2
        ;;
    -t)
        dst=$2
        echo "dest verify config folder : ${dst}"
        shift 2
        ;;
    -o)
        out=$2
        echo "output file : ${out}/verfiy_out.log"
        shift 2
        ;;
    *)
        echo $usage
        exit 1
        ;;
    esac
done
rm -f $out/verfiy_out.log
#for i in $src
for i in `ls  $sourcedir |grep '.html$'`
do
    echo $i
    for j in `ls  $dst`
        do
            perl searchoperation.pl -e $i -f $j 1>/dev/null 2>/dev/null
            if [  $? -eq 0 ] ;then
                echo $j >> $out/verfiy_out.log
            fi
        done
done
exit 0
