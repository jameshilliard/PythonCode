#!/bin/bash
# Author        :   Alex
# Description   :
#   This tool is using to generate FTP configuration file .netrc
#
#
# History       :
#   DATE        |   REV     | AUTH      | INFO
#16 Dec 2011    |   1.0.0   | Alex      | Inital Version       


REV="$0 version 1.0.0 (16 Dec 2011)"
# print REV

echo "${REV}"

cecho() {
    case $1 in
        error)
            echo -e " $2 "
            ;;
        debug)
            echo -e " $2 "
            ;;
    esac
}

msg=""
usage="$0 -d <destination ip|FTP HOST>\n \t\t  -u <login name>\n \t\t  -p <login password>\n \t\t  -src <source file>\n \t\t  -dst <destination path or resave file>\n \t\t  [-s :send file]"
while [ -n "$1" ];
do
    case "$1" in               
        -d)
            FTP_HOST=$2

            shift 2
            ;;

        -u)
            FTP_USER=$2

            echo "basefile name : ${basefile}"

            shift 2
            ;;

        -p)
            FTP_PASSWORD=$2

            echo "verifyfile name : ${verifyfile}"

            shift 2
            ;;

        -src)
            src=$2
            shift 2
            ;;

        -dst)
            dst=$2
            shift 2
            ;;

        -s)
            transmit="send"
            shift 1
            ;;

        -t)
            G_CURRENTLOG=/tmp
            shift 1
            ;;

        *)
            cecho debug "$usage"
            cecho error "result : input error!!!"
            exit 1
            ;;
    esac
done


if [ -z "$FTP_HOST" -o -z "$FTP_USER" -o -z "$FTP_PASSWORD" -o -z "$src" -o -z "$dst" ]; then
    cecho debug "$usage"
    cecho error "result : input error!!!"
    exit 1
fi

if [ -z "$transmit" ]; then
    transmit="get"
fi

if [ "$transmit" = "send" ]; then
    if [ -e $src ]; then
        echo "source file: $src"
    else
        msg="source file $src not exist!"
        cecho error "$msg"
        exit 1
    fi
fi

#generate configuration file /root/.netrc for FTP
if [ "$transmit" = "get" ]; then
    filename=`basename $src`
    FTP_DIR=`dirname $src`
    echo "machine $FTP_HOST" > /root/.netrc
    echo "login $FTP_USER" >> /root/.netrc
    echo "password $FTP_PASSWORD" >> /root/.netrc
    echo "macdef init" >> /root/.netrc
    echo "cd $FTP_DIR" >> /root/.netrc
    echo "ls $filename" >> /root/.netrc
    echo "get $filename $dst/$filename" >> /root/.netrc
    echo "bell" >> /root/.netrc
    echo "close" >> /root/.netrc
    echo "bye" >> /root/.netrc
    echo "" >> /root/.netrc
elif [ "$transmit" = "send" ]; then
    filename=`basename $src`    
    FTP_DIR=$dst
    echo "machine $FTP_HOST" > /root/.netrc
    echo "login $FTP_USER" >> /root/.netrc
    echo "password $FTP_PASSWORD" >> /root/.netrc
    echo "macdef init" >> /root/.netrc
    echo "cd $FTP_DIR" >> /root/.netrc
    echo "put $src $filename" >> /root/.netrc
    echo "ls $filename" >> /root/.netrc
    echo "bell" >> /root/.netrc
    echo "close" >> /root/.netrc
    echo "bye" >> /root/.netrc
    echo "" >> /root/.netrc
fi
chmod 600 /root/.netrc

ftp $FTP_HOST |tee $G_CURRENTLOG/ftp.log

#check result
cecho debug "file name: $filename"
if [ "$transmit" = "get" ]; then
#    cecho debug "loacal"
#    ls -l $dst/$filename
    local_size=`ls -l $dst/$filename | cut -d ' ' -f 5`
elif [ "$transmit" = "send" ]; then
#    cecho debug "loacal"
#    ls -l $src
    local_size=`ls -l $src | cut -d ' ' -f 5`
fi
cecho debug "local file size: $local_size"

#cecho debug "remote"
#cat $G_CURRENTLOG/ftp.log | grep "^-.*$filename$"
remote_size=`cat $G_CURRENTLOG/ftp.log | grep "^-.*$filename$"|awk '{print $(NF-4)}'`
cecho debug "remote file size: $remote_size"

if [ $local_size -gt 0 -a $remote_size -gt 0 ]; then
    msg="transmit file with ftp success!"
    cecho debug "$msg"
    exit 0
else
    msg="transmit file with ftp fail!"
    cecho error "$msg"
    exit 1
fi
