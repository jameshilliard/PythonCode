/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

(function() {
  const Cu = Components.utils;
  const Cr = Components.results;
  const Ci = Components.interfaces;
  const Cc = Components.classes;

  Cu.import("resource://gre/modules/XPCOMUtils.jsm");

  XPCOMUtils.defineLazyModuleGetter(this, "FxaSwitcher",
    "chrome://cmimprove/content/fxa/serviceSwitcher.jsm");

  XPCOMUtils.defineLazyModuleGetter(this, "Services",
    "resource://gre/modules/Services.jsm");

  let _bundles = null;
  function _(key) {
    if (!_bundles) {
      _bundles = Services.strings.createBundle("chrome://cmimprove/locale/fxa.properties");
    }

    return _bundles.GetStringFromName(key);
  }

  function toggle() {
    if (FxaSwitcher.localServiceEnabled) {
      FxaSwitcher.resetFxaServices();
    } else {
      FxaSwitcher.switchToLocalService();
    }
  }

  function updateUI() {
    let toggler = document.getElementById('cn-fxa-switcher');
    toggler.value =
      FxaSwitcher.localServiceEnabled ? _('fxa.preferences.label.switchToGlobal') :
        _('fxa.preferences.label.switchToLocal');

    if (FxaSwitcher.localServiceEnabled) {
      let caption = document.querySelector('#fxaGroup > caption:first-child');
      caption.label = _('fxa.preferences.caption.label');
    }

    // We only change the color of the label that open old sync support page. However, there is
    // no id in this label, let's use an ugly hack to indentify it here ...
    [].forEach.call(document.querySelectorAll('#noFxaAccount label.text-link'), aLabel => {
      if (aLabel.getAttribute('onclick').contains('openOldSyncSupportPage()')) {
        aLabel.style.color = '#999';
      }
    })
  }

  document.getElementById('paneSync').addEventListener('paneload', function() {
    let toggler = document.getElementById('cn-fxa-switcher');
    toggler.onclick = toggle;
    updateUI();
  });
})();

