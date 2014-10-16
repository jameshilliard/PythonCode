#!/bin/bash
echo "this script is used with loopWget.sh"
xterm -e bash ./loopWget.sh 192.168.1  &
xterm -e bash ./loopWget.sh 192.168.2  &
xterm -e bash ./loopWget.sh 192.168.3  &
xterm -e bash ./loopWget.sh 192.168.4  &
xterm -e bash ./loopWget.sh 192.168.5  &