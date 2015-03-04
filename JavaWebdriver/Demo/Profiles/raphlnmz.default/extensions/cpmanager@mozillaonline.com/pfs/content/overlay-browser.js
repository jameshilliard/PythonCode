window.addEventListener("load", function() {
  if (Services.blocklist.getPluginInfoURL) {
    return;
  }

  var pluginHandler = {
    handleEvent: function(event) {
      var eventType = event.type;

      if (eventType == "PluginBindingAttached") {
        var plugin = event.target;
        var doc = plugin.ownerDocument;

        if (!(plugin instanceof Ci.nsIObjectLoadingContent))
          return;
        var overlay = doc.getAnonymousElementByAttribute(plugin, "anonid", "checkForUpdatesLink");
        overlay.textContent = gNavigatorBundle.getString("pluginActivate.updateLabel");
      }
    }
  };

  gBrowser.addEventListener("PluginBindingAttached", pluginHandler, true, true);
  function getFlashUpdateUrl() {
    var os = Services.appinfo.OS;
    if (os == "WINNT") {
      return Services.urlFormatter.formatURLPref("plugins.update.flash.WINNT.url");
    } else if (os == "Darwin") {
      return Services.urlFormatter.formatURLPref("plugins.update.flash.Darwin.url");
    } else {
      return Services.urlFormatter.formatURLPref("plugins.update.url");
    }
  }
  if (gPluginHandler && gPluginHandler.openPluginUpdatePage) {
    var openPluginUpdatePage = gPluginHandler.openPluginUpdatePage;
    gPluginHandler.openPluginUpdatePage = function(aEvent) {
      try {
        var node = aEvent.target;
        if (node.tagName.toLowerCase() != "object" && node.tagName.toLowerCase() != "embed") {
          node = document.getBindingParent(aEvent.target);
        }
        var info = gPluginHandler._getPluginInfo(node)
        var type = info.mimetype;
        var os = Services.appinfo.OS;
        if (type == "application/x-shockwave-flash" && os == "WINNT") {
          openUILinkIn(Services.urlFormatter.formatURLPref("plugins.update.flash.WINNT.url"), "current");
        } else if (type == "application/x-shockwave-flash" && os == "Darwin") {
          openURL(Services.urlFormatter.formatURLPref("plugins.update.flash.Darwin.url"));
        } else {
          openPluginUpdatePage(aEvent);
        }
      } catch (e) {
        openPluginUpdatePage(aEvent);
      }
    }
  }

  if (gPluginHandler && gPluginHandler._clickToPlayNotificationEventCallback
                     && gPluginHandler._showClickToPlayNotification) {
    var _showClickToPlayNotification = gPluginHandler._showClickToPlayNotification.bind(gPluginHandler);
    gPluginHandler._showClickToPlayNotification = (function(aBrowser, aPrimaryPlugin) {
      _showClickToPlayNotification(aBrowser, aPrimaryPlugin);
      var notification = PopupNotifications.getNotification("click-to-play-plugins", aBrowser);
      if (!notification) {
        return;
      }
      //show panel now
      var panel = document.getElementById("click-to-play-plugins-notification");
      if (panel) {
        var cas = panel.notification.options.centerActions || [];
        cas.forEach(function(ca) {
          if (ca.mimetype == "application/x-shockwave-flash") {
            var link = document.getAnonymousElementByAttribute(panel, "anonid", "click-to-play-plugins-notification-link");
            link.href = getFlashUpdateUrl();
          }
        });
      }
      //show panel later
      notification.options.eventCallback = function(event) {
        gPluginHandler._clickToPlayNotificationEventCallback.bind(this)(event);
        if (event == "showing") {
          var cas = this.options.centerActions || [];
          cas.forEach(function(ca) {
            if (ca.mimetype == "application/x-shockwave-flash") {
              ca.detailsLink = getFlashUpdateUrl();
            }
          });
        }
      };
    }).bind(gPluginHandler)
  }
}, false);
