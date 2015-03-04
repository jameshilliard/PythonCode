// based on /browser/components/downloads/src/DownloadsStartup.js

"use strict";

const Ci = Components.interfaces;
const Cu = Components.utils;

Cu.import("resource://gre/modules/XPCOMUtils.jsm");

const kUCHCCid = Components.ID("{122d6f90-2f84-4e0a-8d26-f2bd906c5e80}");
const kUCHCContractId = "@mozilla.org/url-classifier/hashcompleter;1";

function UCHCStartup() { }

UCHCStartup.prototype = {
  classID: Components.ID("{547a9101-517b-41a8-8e46-0b63b6ec818a}"),

  _xpcom_factory: XPCOMUtils.generateSingletonFactory(UCHCStartup),

  QueryInterface: XPCOMUtils.generateQI([Ci.nsIObserver]),

  observe: function (aSubject, aTopic, aData)
  {
    if (aTopic != "profile-after-change") {
      Cu.reportError("Unexpected observer notification.");
      return;
    }

    Components.manager.QueryInterface(Ci.nsIComponentRegistrar)
                      .registerFactory(kUCHCCid, "",
                                       kUCHCContractId, null);
  },
};

this.NSGetFactory = XPCOMUtils.generateNSGetFactory([UCHCStartup]);
