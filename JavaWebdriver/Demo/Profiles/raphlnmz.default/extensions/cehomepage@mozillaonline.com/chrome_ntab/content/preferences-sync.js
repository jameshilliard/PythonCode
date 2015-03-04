var mozCNNTabSync = (function() {
  // this cannot be done with an overlay, sigh
  let qs = document.querySelector.bind(document);
  let paneSync = qs('#paneSync');

  let onPaneLoad = function() {
    paneSync.removeEventListener('paneload', onPaneLoad);
    let parentVBox = qs("#fxaSyncEngines > vbox");
    let checkbox = qs('checkbox[preference="engine.mozcn.ntab"]');
    if (!parentVBox || !checkbox) {
      return;
    }

    parentVBox.appendChild(checkbox.cloneNode());
  };

  paneSync.addEventListener('paneload', onPaneLoad, false);

  // prompt for confirmation for every false => true change
  let url = "chrome://ntab/locale/sync.properties";
  let bundle = Services.strings.createBundle(url);
  let prefix = "ntabsync.notification.";
  let message = bundle.GetStringFromName(prefix + "message");
  let title = bundle.GetStringFromName(prefix + "title");

  let onSyncToEnablePref = function(aCheckbox) {
    if (!aCheckbox.checked) {
      return undefined;
    }
    let shouldEnable = Services.prompt.confirm(window, title, message);

    if (!shouldEnable) {
      aCheckbox.checked = false;
    }
  };

  return { onSyncToEnablePref: onSyncToEnablePref };
})();
