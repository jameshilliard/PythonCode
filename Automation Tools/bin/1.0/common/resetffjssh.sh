#!/bin/bash
killall firefox 
killall firefox-bin
rm -rf ~/.mozilla/firefox/*/compreg.dat
#echo "user_pref(\"browser.sessionstore.resume_from_crash\", false);"  >> ~/.mozilla/firefox/*.default/prefs.js
#firefox -CreateProfile automation
#/usr/bin/firefox -P automation -jssh &
