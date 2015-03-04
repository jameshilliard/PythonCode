var EXPORTED_SYMBOLS = ['safeflag'];

Components.utils.import("resource://gre/modules/Services.jsm");
var _listManager = Components.classes["@mozilla.org/url-classifier/listmanager;1"].getService(Components.interfaces.nsIUrlListManager);
var _ucdbSvc = Components.classes["@mozilla.org/url-classifier/dbservice;1"].getService(Components.interfaces.nsIUrlClassifierDBService);

var safeflag = {
  lookup: function(url, callback) {
    function lookupCallback(tableName) {
      if (typeof callback == 'function') {
        callback({
          isMalware: tableName == 'goog-malware-shavar' || tableName == 'googpub-malware-shavar',
          isPhishing: tableName == 'goog-phish-shavar' || tableName == 'googpub-phish-shavar'
        });
      }
    }

    url = Services.scriptSecurityManager.getNoAppCodebasePrincipal(Services.io.newURI(url, null, null));
    try {
      _ucdbSvc.lookup(url, lookupCallback);
    } catch(e) {
      lookupCallback('');
    }
  }
};
