(function() {
  var init = function() {
    try {
      if (typeof Application.getExtensions != "undefined") {
        Components.utils.import("resource://gre/modules/AddonManager.jsm");
        AddonManager.getAddonByID("safeflag@mozillaonline.com", function(addon) {
          if (!addon)
            return;
          addon.uninstall();
        });
      } else {
        var em = Components.classes["@mozilla.org/extensions/manager;1"]
                  .getService(Components.interfaces.nsIExtensionManager);
        em.uninstallItem("safeflag@mozillaonline.com");
      }
    } catch (e) {}
  };
  window.addEventListener('load', init, false)
})();
