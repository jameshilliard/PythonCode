(function() {
  var ns = MOA.ns('SafeFlag.Monitor')

  var Cc = Components.classes;
  var Ci = Components.interfaces;
  var Cu = Components.utils;
  var Cr = Components.results;

  Cu['import']('resource://cmsafeflag/safeflag.jsm');
  // Current tab id which used to check if lookup callback is for current tab.
  var _current_tab_id_ = null;

  // Store safe info for tab, including:
  //   url:      for checking if tab url has been changed.
  //   safeflag: safe flag checking result, if url is not changed, then reuse it.
  var _tab_url_safeflag_ = {};

  var progListener = {
    QueryInterface: function(iid) {
      if (iid.equals(Ci.nsISupports) ||
        iid.equals(Ci.nsISupportWeakReference) ||
        iid.euqals(Ci.nsIWebProgressListener)) {
        return this;
      }

      throw Cr.NS_ERROR_NO_INTERFACE;
    },

    onStateChange:    function() {},
    onProgressChange: function() {},
    onStatusChange:   function() {},
    onSecurityChange: function() {},
    onLocationChange: function(webProgress, request, uri) {
      var win = webProgress.DOMWindow;
      var tabId = MOA.SafeFlag.Utils.getTabIdForWindow(win);
      if (!tabId)
        return;

      let isTopLevel = webProgress.isTopLevel || win == win.top;
      if (!isTopLevel) {
          return;
      }

      MOA.debug(tabId + ', uri: ' + uri);

      _current_tab_id_ = tabId;
      if (!uri) {
        // When a new tab is opened, uri is null.
        _updateIcon(uri);
        return;
      }

      var url_safeflag = _tab_url_safeflag_[tabId];

      if (!url_safeflag || url_safeflag.url != uri.spec) {
        _tab_url_safeflag_[tabId] = {
          url: uri.spec,
          safe_flag: null
        };

        safeflag.lookup(uri.spec, MOA.SafeFlag.Utils.bindFunc(function(result) {
          _tab_url_safeflag_[this].safe_flag = result;
          if (_current_tab_id_ == this) {
            MOA.debug('Update icons');
            _updateIcon();
          }
        }, tabId));

        _updateIcon();
        return;
      }

      if (url_safeflag.url == uri.spec && null != url_safeflag.safe_flag) {
        _updateIcon();
      }
    },

    handleEvent: function(event) {
      _onTabClose(event.target.linkedPanel);
    }
  };

  function _onTabClose(tabId) {
    delete _tab_url_safeflag_[tabId];
  }

  function _getIconPath(filename) {
    return "chrome://cmsafeflag/content/icons/" + filename + ".png";
  }

  function _updateIcon() {
    MOA.SafeFlag.Layout.updateIcon();
  }

  ns.getCurrentTabSafeflag = function() {
    if (!_tab_url_safeflag_[_current_tab_id_] || !_tab_url_safeflag_[_current_tab_id_].safe_flag || (gInitialPages.indexOf(_tab_url_safeflag_[_current_tab_id_].url) > -1)) {
      return null;
    }

    return _tab_url_safeflag_[_current_tab_id_].safe_flag;
  };

  ns.init = function() {
    // do not use any mask which cause an "error" on Firefox5:
    // Error: gBrowser.addProgressListener was called with a second argument, which is not supported. See bug 608628.
    // Source: chrome://browser/content/tabbrowser.xml
    // Line: 1840
    gBrowser.addProgressListener(progListener/*, Ci.nsIWebProgress.NOTIFY_LOCATION*/);
    gBrowser.tabContainer.addEventListener('TabClose', progListener, false);
  }

  ns.stop = function() {
    gBrowser.removeProgressListener(progListener);
    gBrowser.tabContainer.removeEventListener('TabClose', progListener, false);
  }

  if (MOA.SafeFlag.Utils.getPrefs().getBoolPref("enable")) {
    window.addEventListener('load', function(evt) {
      MOA.SafeFlag.Monitor.init()
    }, false);
  }
})();
