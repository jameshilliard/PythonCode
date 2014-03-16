#!/bin/bash

#####################################
#
# Setting up BitTorrent client enviorment for testing
# 2009.9.25
#
####################################

#-------------------------------------------------------------
# pre-setting up :
#   1. install rtorront
#   2. update BT file ./automation/lib/1.0/common/.rtorrent.rc
#   3. download BT seeds ./automation/download/btdownload/
#-------------------------------------------------------------

# enter ./automation/lib/1.0/common/
lib
/bin/cp -f .rtorrent.rc ~/

# set up document for torrent
cd /home
mkdir filedownload
cd filedownload
mkdir session
mkdir downloads
mkdir torrent

# cp seeds of bt to destination
tools
/bin/cp -f ./1.0/btseeds/* /home/filedownload/torrent

# launch BT client
screen rtorrent
wait 1000

# stop bt process
process=`ps aux|grep rtorrent | grep -v "grep" |awk '{print $2}'`

kill -9 $process

