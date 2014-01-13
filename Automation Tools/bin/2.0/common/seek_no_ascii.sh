#!/bin/bash - 
#===============================================================================
#
#          FILE: seek_no_ascii.sh
# 
#         USAGE: ./seek_no_ascii.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 04/12/2013 05:45:57 PM CST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error



dest_file=$1


mm=`cat "$dest_file" | wc -m`
cc=`cat "$dest_file" | wc -c`

echo "In file : $dest_file"
echo "total character counts : $mm"
echo "total byte      counts : $cc"

if [ $mm == $cc ]; then
    echo "all ascii char in file : $dest_file"
    exit 1
else
    i=0
    echo "lines contain char exclude ascii in file ( $dest_file ) : "
    cat -n $dest_file | while read LINE
    do
        mm=`echo $LINE | wc -m`
        cc=`echo $LINE | wc -c`
        if [ $mm == $cc ]; then
            #
            x='1'
        else
            #i=$($i + 1)
            echo "$LINE"
        fi
    done
    echo ''
    exit 0
fi


