(function() {
  const {classes: Cc, interfaces: Ci, utils: Cu, results: Cr} = Components;
  const DOWNLOAD_URL = "http://download.firefox.com.cn/releases/mobile/latest/zh-CN/firefox-android-latest.apk";
  const TRACK_URL = "http://addons.g-fox.cn/fennecInstaller.gif";

  Cu.import("resource://gre/modules/XPCOMUtils.jsm");

  let ack = 0;
  let oneClickInstall = 0;
  let downloadPkg = 0;

  XPCOMUtils.defineLazyModuleGetter(this, 'Services', 'resource://gre/modules/Services.jsm');

  let prefs = Services.prefs.getBranch("extensions.fennecinstaller@mozillaonline.com.");

  document.addEventListener("acknowledge", function(e) {
    ack = 1;
    prefs.setBoolPref("enabled", false);
    Services.prefs.setIntPref("plugin.state.npfennecinstaller", 0);
    window.close();
  }, false, true);

  document.addEventListener("oneClickInstall", function(e) {
    oneClickInstall = 1;
    prefs.setBoolPref("enabled", false);
    Services.prefs.setIntPref("plugin.state.npfennecinstaller", 0);
  }, false, true);

  document.addEventListener("downloadPackage", function(e) {
    downloadPkg = 1;
    prefs.setBoolPref("enabled", false);
    Services.prefs.setIntPref("plugin.state.npfennecinstaller", 0);
    let win = Services.wm.getMostRecentWindow('navigator:browser');
    if (win) {
      win.gBrowser.selectedTab = win.gBrowser.addTab(DOWNLOAD_URL);
    }
    window.close();
  }, false, true);

  window.addEventListener('unload', function() {
    let tracker = Components.classes["@mozilla.com.cn/tracking;1"];
    if (!tracker || !tracker.getService().wrappedJSObject.ude) {
      return;
    }
    // Life cycle of XMLHttpRequest object created this way is longer than window object.
    let url = TRACK_URL + "?show=1&ack=" + ack + "&oneClickInstall=" + oneClickInstall + "&downloadPkg=" + downloadPkg;
    let xhr = Cc["@mozilla.org/xmlextras/xmlhttprequest;1"].createInstance(Ci.nsIXMLHttpRequest);
    xhr.open('GET', url, true);
    xhr.send();
  }, false);
})();