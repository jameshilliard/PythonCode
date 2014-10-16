#!/bin/bash
usage="compare_dir_html.sh -s <source dir> -d <dest dir> -o <output dir>"
while [ -n "$1" ];
do
    case "$1" in

    -s)
        sourcedir=$2
        echo "source : ${sourcedir}"
        shift 2
        ;;
    -d)
        destdir=$2
        echo "dest : ${destdir}"
        shift 2
        ;;
    -o)
        outdir=$2
        echo "outdir : ${outdir}"
        shift 2
        ;;
    *)
        echo "compare_dir_html.sh -s <source dir> -d <dest dir> -o <output dir>"
        exit 1
        ;;
    esac
done

if [ -z $sourcedir ]; then
	echo $usage
	exit 1
fi

if [ -z $destdir ]; then
	echo $usage
	exit 1
fi

if [ -z $outdir ]; then
	echo $usage
	exit 1
fi


rm -f $outdir/compare_out.log

for i in `ls  $sourcedir |grep '.html$'`
do
    diff $sourcedir/$i $destdir/$i 1>/dev/null 2>/dev/null
    if [  $? -ne 0 ] ;then
        echo $i >> $outdir/compare_out.log
    fi
done
exit 0
