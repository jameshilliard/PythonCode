#!/bin/bash
sleep_interval=3
./wlx86 -i wlan3 down
sleep $sleep_interval
./wlx86 restart
sleep $sleep_interval

./wlx86 -i wlan3 up
sleep $sleep_interval
./wlx86 -i wlan3 status

./wlx86 -i wlan3 auth 0
sleep $sleep_interval
./wlx86 -i wlan3 status


./wlx86 -i wlan3 infra 1
sleep $sleep_interval
./wlx86 -i wlan3 status

./wlx86 -i wlan3 wsec 1
sleep $sleep_interval
./wlx86 -i wlan3 status

./wlx86 -i wlan3 sup_wpa 1
sleep $sleep_interval
./wlx86 -i wlan3 status

./wlx86 -i wlan3 wpa_auth 0
sleep $sleep_interval
./wlx86 -i wlan3 status

./wlx86 -i wlan3 addwep 0 1234567890
sleep $sleep_interval
echo $?
./wlx86 -i wlan3 status

./wlx86 -i wlan3 mac 40:8b:07:e0:02:55
sleep $sleep_interval
./wlx86 -i wlan3 status

sleep $sleep_interval
./wlx86 -i wlan3 ssid CenturyLink0006

sleep 5

./wlx86 -i wlan3 status

dhclient -v -r wlan3
dhclient -v wlan3
