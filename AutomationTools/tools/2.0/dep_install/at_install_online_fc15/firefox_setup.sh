#!/bin/bash

# firefox setting
echo "user_pref(\"browser.sessionstore.resume_from_crash\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
echo "user_pref(\"browser.download.manager.showWhenStarting\", false);" >> ~/.mozilla/firefox/*.default/prefs.js

#create a firefox profile 
killall firefox
echo " Make sure enter automation as profile manager"
firefox -ProfileManager
# add jssh
firefox --install-global-extension jssh-20081108-Linux.xpi
# add bypass certificate error
firefox --install-global-extension remember_certificate_exception-0.8.0-fx.xpi
#echo " make sure that  /usr/lib/firefox-*/extensions/jssh@extensions.mozilla.org is existed"
ls -al /usr/lib/firefox-*/extensions/jssh@extensions.mozilla.org
