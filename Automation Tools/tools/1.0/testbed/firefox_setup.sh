#!/bin/bash
echo "user_pref(\"browser.sessionstore.resume_from_crash\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
echo "user_pref(\"browser.download.manager.showWhenStarting\", false);" >> ~/.mozilla/firefox/*.default/prefs.js
