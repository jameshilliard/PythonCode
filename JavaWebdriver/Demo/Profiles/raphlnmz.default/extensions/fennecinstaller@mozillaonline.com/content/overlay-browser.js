/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

(function() {
  const {classes: Cc, interfaces: Ci, utils: Cu, results: Cr} = Components;
  const CONFIG_URL = "http://i.g-fox.cn/notification/fennec_installer_rules.json";

  let DEBUG = 0;
  var debug = function _debug(s) {
    if (DEBUG) {
      let console = Cc["@mozilla.org/consoleservice;1"].getService(Ci.nsIConsoleService);
      console.logStringMessage("-*- FennecInstaller overlay: " + s + "\n");
    }
  };

  let prefs = Services.prefs.getBranch("extensions.fennecinstaller@mozillaonline.com.");

  let configUpdateTime = prefs.getIntPref("config_update_time");
  // Update configuration after 24 hours.
  configUpdateTime += 1000 * 60 * 60 * 24;
  let now = Date.now();

  if (now > configUpdateTime) {
    let xhr = new XMLHttpRequest();
    xhr.responsType = "json";
    xhr.open("GET", CONFIG_URL, true);
    xhr.onload = function() {
      prefs.setIntPref("config_update_time", now);
      debug(xhr.responseText);
      let jsonRes = JSON.parse(xhr.responseText);
      prefs.setIntPref("max_popup_count", jsonRes.MAX_COUNT);
      prefs.setIntPref("interval_days", jsonRes.INTERVAL_DAYS);
    };
    xhr.send();
  }

  function checkEnabled() {
    return prefs.getBoolPref("enabled");
  }

  function checkPopupCount() {
    let popupCount = prefs.getIntPref("popup_count");
    let maxPopupCount = prefs.getIntPref("max_popup_count");
    return maxPopupCount > popupCount;
  }

  function checkInterval() {
    let lastPopupTime = prefs.getIntPref("last_popup_time");
    let intervalDays = prefs.getIntPref("interval_days");
    // Popup one time within interval days.
    lastPopupTime *= 1000;
    lastPopupTime += 1000 * 60 * 60 * 24 * intervalDays;
    return Date.now() > lastPopupTime;
  }

  function init() {
    window.ondeviceconnected = function() {
      console.log('device has been connected');
      if (!checkEnabled() || !checkPopupCount()) return;
      if (!checkInterval()) return;

      prefs.setIntPref("popup_count", prefs.getIntPref("popup_count") + 1);
      prefs.setIntPref("last_popup_time", Date.now() / 1000);
      window.openDialog("chrome://fennecinstaller/content/dialog.xul", "Fennec_Installer_Dialog", "centerscreen,outerHeight=500,outerWidth=760");
    };
  };

  window.addEventListener("load", function(event) {
    init();
  });
})();
