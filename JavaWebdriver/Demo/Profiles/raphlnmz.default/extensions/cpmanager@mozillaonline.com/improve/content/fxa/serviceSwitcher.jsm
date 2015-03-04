/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

let EXPORTED_SYMBOLS = ['FxaSwitcher'];

const Ci = Components.interfaces;
const Cu = Components.utils;
const Cc = Components.classes;

let TOKEN_SERVER     = 'https://sync.firefox.com.cn';
let AUTH_SERVER      = 'https://api-accounts.firefox.com.cn';
let ACCOUNTS_SERVER  = 'https://accounts.firefox.com.cn';

const DEBUG = 0;

/* Only for test */
const useTestDomain = 0;
if (useTestDomain) {
  TOKEN_SERVER       = 'https://sync.testfirefox.com.cn';
  AUTH_SERVER        = 'https://api-accounts.testfirefox.com.cn';
  ACCOUNTS_SERVER    = 'https://accounts.testfirefox.com.cn';
}

const TOKEN_SERVER_URI = TOKEN_SERVER    + '/token/1.0/sync/1.5';
const AUTH_URI         = AUTH_SERVER     + '/v1';
const FORCE_AUTH_URI   = ACCOUNTS_SERVER + '/force_auth?service=sync&context=fx_desktop_v1';
const SIGHIN_URI       = ACCOUNTS_SERVER + '/signin?service=sync&context=fx_desktop_v1';
const SIGHUP_URI       = ACCOUNTS_SERVER + '/signup?service=sync&context=fx_desktop_v1';
const REMOTE_URI       = ACCOUNTS_SERVER + '/?service=sync&context=fx_desktop_v1';
const SETTINGS_URI     = ACCOUNTS_SERVER + '/settings';
const PRIVACY_URL      = ACCOUNTS_SERVER + '/legal/privacy';
const TERMS_URL        = ACCOUNTS_SERVER + '/legal/terms';
const STATUS_URL       = ACCOUNTS_SERVER + '/status/';

const PREF_SYNC_TOKENSERVER = 'services.sync.tokenServerURI';

const PREF_RESTART_FLAG = 'extensions.cpmanager@mozilla.com.flag.restart';

const SERVICE_PREFS = {
  'identity.fxaccounts.auth.uri': AUTH_URI,
  'identity.fxaccounts.remote.force_auth.uri': FORCE_AUTH_URI,
  'identity.fxaccounts.remote.signin.uri': SIGHIN_URI,
  'identity.fxaccounts.remote.signup.uri': SIGHUP_URI,
  'identity.fxaccounts.remote.uri': REMOTE_URI,
  'identity.fxaccounts.settings.uri': SETTINGS_URI,
  'services.sync.statusURL': STATUS_URL,
  'services.sync.fxa.privacyURL': PRIVACY_URL,
  'services.sync.fxa.termsURL': TERMS_URL,
  'services.sync.fxaccounts.enabled': true

};

SERVICE_PREFS[PREF_SYNC_TOKENSERVER] = TOKEN_SERVER_URI;

const WEAVE_STARTOVER_FINISH = 'weave:service:start-over:finish';

const UT_NO_SYNC_USED    = 'ut_no_sync_used';
const UT_FXA_USED        = 'ut_fxaccount_used';
const UT_WEAVE_USED      = 'ut_weave_used';
const UT_CN_FXA_SWITCHED = 'ut_cn_fxa_switched';
const ONE_CHECK_PREF = 'cpmanager@mozillaonline.com.switch_fxa_pref.checked';

Cu.import("resource://gre/modules/XPCOMUtils.jsm");

XPCOMUtils.defineLazyModuleGetter(this,
  'Weave', 'resource://services-sync/main.js');

XPCOMUtils.defineLazyModuleGetter(this,
  'fxAccounts', 'resource://gre/modules/FxAccounts.jsm');

XPCOMUtils.defineLazyModuleGetter(this,
  'Promise', 'resource://gre/modules/Promise.jsm');

XPCOMUtils.defineLazyModuleGetter(this, "Services",
  "resource://gre/modules/Services.jsm");

let _bundles = null;
function _(key) {
  if (!_bundles) {
    _bundles = Services.strings.createBundle("chrome://cmimprove/locale/fxa.properties");
  }

  return _bundles.GetStringFromName(key);
}

function localServiceEnabled() {
  return Services.prefs.getCharPref(PREF_SYNC_TOKENSERVER) ==
           TOKEN_SERVER_URI;
}

PrefWatchDog = {
  observe: function(aSubject, aTopic, aData) {
    switch (aTopic) {
      case WEAVE_STARTOVER_FINISH:
        repairPrefs();
        break;
    }
  }
};

/**
 * services.sync.* prefs are reset after user disconnected, we need to
 * observe WEAVE_STARTOVER_FINISH topic and change some of them back.
 */
function startPrefWatchDog() {
  Services.obs.addObserver(PrefWatchDog, WEAVE_STARTOVER_FINISH, false);
}

function debug(msg) {
  if (DEBUG) {
    Cu.reportError('CP:FXA: ' + msg);
  }
}

/**
 * Get the account service usage type of current profile. One of the
 * const values with prefix UT_* is returned.
 */
function getUsageType() {
  let { promise, resolve } = Promise.defer()

  if (localServiceEnabled()) {
    resolve(UT_CN_FXA_SWITCHED);
    return promise;
  }

  // Borrow some codes from chrome://browser/content/preferences/sync.js
  let service = Cc["@mozilla.org/weave/service;1"]
                  .getService(Ci.nsISupports)
                  .wrappedJSObject;

  debug('Weave status: ' + Weave.Status);

  // If fxAccountsEnabled is false, fxa is in a "not configured" state.
  if (service.fxAccountsEnabled) {
    fxAccounts.getSignedInUser().then(function(data) {
      if (data) {
        debug('Fxa data: ' + JSON.stringify(data));
        resolve(UT_FXA_USED);
      } else {
        resolve(UT_NO_SYNC_USED);
      }
    });
  } else if (typeof Weave == 'undefined') {
    // No Weave object.
    resolve(UT_NO_SYNC_USED);
  } else if (Weave.Status.service == Weave.CLIENT_NOT_CONFIGURED ||
             Weave.Svc.Prefs.get("firstSync", "") == "notReady") {
    // No Weave accounts.
    resolve(UT_NO_SYNC_USED);
  } else if (Weave.Status.login == Weave.LOGIN_FAILED_INVALID_PASSPHRASE ||
             Weave.Status.login == Weave.LOGIN_FAILED_LOGIN_REJECTED) {
    // Weave login failed.
    resolve(UT_WEAVE_USED);
  } else {
    resolve(UT_WEAVE_USED);
  }

  return promise;
}

function resetFxaServices() {
  if (!localServiceEnabled()) {
    return;
  }

  Object.keys(SERVICE_PREFS).forEach(function(key) {
    Services.prefs.clearUserPref(key);
  });
}


function onlySyncBookmark() {
  [
    { key: 'services.sync.engine.addons', value: false},
    { key: 'services.sync.engineStatusChanged.addons', value: true },
    { key: 'services.sync.engine.history', value: false},
    { key: 'services.sync.engineStatusChanged.history', value: true },
    { key: 'services.sync.engine.passwords', value: false},
    { key: 'services.sync.engineStatusChanged.passwords', value: true },
    { key: 'services.sync.engine.prefs', value: false},
    { key: 'services.sync.engineStatusChanged.prefs', value: true },
    { key: 'services.sync.engine.tabs', value: false},
    { key: 'services.sync.engineStatusChanged.tabs', value: true },
    { key: 'services.sync.engineStatusChanged.prefs.modified', value: true }
  ].forEach(aKeyValue => {
    Services.prefs.setBoolPref(aKeyValue.key, aKeyValue.value);
  });
}

function switchToLocalService(aOnlyForSyncPrefs) {
  Object.keys(SERVICE_PREFS).forEach(function(key) {
    if (aOnlyForSyncPrefs && !key.startsWith('services.sync.')) {
      return;
    }

    if (typeof SERVICE_PREFS[key] == 'string') {
      Services.prefs.setCharPref(key, SERVICE_PREFS[key]);
    } else if (typeof SERVICE_PREFS[key] == 'boolean') {
      Services.prefs.setBoolPref(key, SERVICE_PREFS[key]);
    }
  });
}

function alreadyChecked() {
  try {
    return Services.prefs.getBoolPref(ONE_CHECK_PREF, false);
  } catch (e) {
    return false;
  }
}

function markChecked() {
  Services.prefs.setBoolPref(ONE_CHECK_PREF, true);
}

function repairPrefs() {
  // In such a case, the prefs will be messy:
  //   - User upgraded passport addon but without the latest cpmanager.
  //   - User finished the migration process, then the passport addon
  //     uninstalled itself.
  //   - User logged out fxa account.
  //   - User tried to login again, it failed, because the tokenServerURI
  //     pref is reset without pref-watchdog protection.
  //
  // we try to clean the mess here.
  var hasLocalPref = Object.keys(SERVICE_PREFS).some(function(key) {
    try {
      if (typeof SERVICE_PREFS[key] == 'string') {
        return Services.prefs.getCharPref(key) == SERVICE_PREFS[key];
      } else if (typeof SERVICE_PREFS[key] == 'boolean') {
        return Services.prefs.getBoolPref(key) == SERVICE_PREFS[key];
      }
    } catch (e) {
      return false;
    }
  });

  if (hasLocalPref) {
    debug('change it back.');
    // For some unknown reason, we have hundreds of global users who are using
    // our sync server, we haven't decide how to deal with it (bug 1645). To
    // prevent impacting those unexpected users, let's just change prefs with
    // prefix services.sync.*
    switchToLocalService(/* aOnlyForSyncPrefs =*/ true);
  }
}

function init() {
  // Complete unfinished jobs before FF restarted.
  doUnfinishedJobs();

  repairPrefs();

  if (alreadyChecked()) {
    startPrefWatchDog();
    done();
    return;
  }

  getUsageType().then(aType => {
    debug('user type: ' + aType + '\n');
    switch(aType) {
      case UT_NO_SYNC_USED:
      case UT_WEAVE_USED:
        switchToLocalService();
        onlySyncBookmark();
        break;
      default:
        debug('Ignore for ' + aType);
        break;
    }
  }).then(() => {
    debug('Switch prefs done.');
    startPrefWatchDog();
    markChecked();
    done();
  }, e => {
    debug('error: ' + e);
    done();
  });
}

let statusListener = [];
let isDone = false;

function done() {
  isDone = true;
  statusListener.forEach(callback => {
    try {
      callback();
    } catch (e) {}
  });
}

function doUnfinishedJobs() {
  try {
    if (!Services.prefs.getBoolPref(PREF_RESTART_FLAG, false)) {
      return;
    }
  } catch (e) {
    return;
  }

  Services.prefs.clearUserPref(PREF_RESTART_FLAG);
  doSendTrack();
}

function sendTrackIfAllowed() {
  // Only mark pref, do tracking after FF restarted.
  Services.prefs.setBoolPref(PREF_RESTART_FLAG, true);
}

function doSendTrack() {
  var tracker = Cc["@mozilla.com.cn/tracking;1"];
  if (!tracker || !tracker.getService().wrappedJSObject.ude) {
    return;
  }

  let url = 'http://addons.g-fox.cn/fxa-switch.gif?fxa=' + localServiceEnabled();
  let xhr = Cc["@mozilla.org/xmlextras/xmlhttprequest;1"].
              createInstance(Ci.nsIXMLHttpRequest);

  xhr.onload = function() {
    debug("Stats sent: " + url);
  };

  xhr.open("GET", url, true);
  xhr.send();
}

let FxaSwitcher = {
  /**
   * This along with addStatusListener/removeStatusListener are used by passport addon,
   * in case we didn't finish fxa entries checking/switching before passport addon
   * start migration process.
   */
  get isDone() {
    return isDone;
  },

  get localServiceEnabled() {
    return localServiceEnabled();
  },

  addStatusListener: function(listener) {
    if (statusListener.indexOf(listener) > -1) {
      return;
    } else {
      statusListener.push(listener);
    }
  },

  removeStatusListener: function(listener) {
    let index = statusListener.indexOf(listener);
    if (index > -1) {
      statusListener.splice(index, 1);
    }
  },

  resetFxaServices: function() {
    let title = _('fxa.confirm.title.switchToGlobal');
    let body = _('fxa.confirm.body.switchToGlobal');
    if (Services.prompt.confirm(null, title, body)) {
      resetFxaServices();
      sendTrackIfAllowed();
      Cc['@mozilla.org/toolkit/app-startup;1'].getService(Ci.nsIAppStartup)
        .quit(Ci.nsIAppStartup.eForceQuit | Ci.nsIAppStartup.eRestart);
    }
  },

  switchToLocalService: function() {
    let title = _('fxa.confirm.title.switchToLocal');
    let body = _('fxa.confirm.body.switchToLocal');
    if (Services.prompt.confirm(null, title, body)) {
      switchToLocalService();
      sendTrackIfAllowed();
      // Restart anyway.
      Cc['@mozilla.org/toolkit/app-startup;1'].getService(Ci.nsIAppStartup)
        .quit(Ci.nsIAppStartup.eForceQuit | Ci.nsIAppStartup.eRestart);
    }
  }
};

init();

