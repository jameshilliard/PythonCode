let Cu = Components.utils;
let Ci = Components.interfaces;
let Cc = Components.classes;
Cu.import('resource://ntab/NTabSync.jsm');
Cu.import('resource://ntab/Tracking.jsm');

let document = content.document;

let DefaultBrowser = {
  get setDefault() {
    delete this.setDefault;
    return this.setDefault = document.querySelector('#setdefault');
  },
  // shellService is not universally available, see https://bugzil.la/297841
  get shellService() {
    let shellService = null;
    try {
      shellService = Cc['@mozilla.org/browser/shell-service;1'].
                       getService(Ci.nsIShellService);
    } catch(e) {}
    delete this.shellService;
    return this.shellService = shellService;
  },
  init: function DefaultBrowser_init() {
    if (!this.setDefault) {
      return;
    }

    if (!this.shellService || this.shellService.isDefaultBrowser(true)) {
      return;
    }

    let self = this;
    this.setDefault.addEventListener('click', function(evt) {
      self.setAsDefault(evt);
    }, false, /** wantsUntrusted */false);
    this.setDefault.removeAttribute('hidden');
  },
  setAsDefault: function DefaultBrowser_setAsDefault(aEvt) {
    if (this.shellService) {
      this.shellService.setDefaultBrowser(true, false);
    }
    this.setDefault.setAttribute('hidden', 'true');
  },
};

let Launcher = {
  get launcher() {
    delete this.launcher;
    return this.launcher = document.querySelector('#launcher');
  },
  get tools() {
    delete this.tools;
    return this.tools = document.querySelector('li[data-menu="tools"]');
  },
  init: function Launcher_init() {
    if (!this.tools) {
      return;
    }

    this.tools.removeAttribute('hidden');

    let self = this;
    [].forEach.call(document.querySelectorAll('#tools > li'), function(li) {
      li.addEventListener('click', function(aEvt) {
        self.launcher.classList.toggle('tools');

        sendAsyncMessage('mozCNUtils:Tools', aEvt.currentTarget.id);

        Tracking.track({
          type: 'tools',
          action: 'click',
          sid: aEvt.currentTarget.id
        });
      }, false, /** wantsUntrusted */false);
    });
  }
};

let FxAccounts = {
  _inited: false,
  _cachedMessages: [],

  messageName: 'mozCNUtils:FxAccounts',
  attributes: [
    "disabled",
    "failed",
    "hidden",
    "label",
    "signedin",
    "status",
    "tooltiptext"
  ],

  get button() {
    delete this.button;
    return this.button = document.querySelector('#fx-accounts');
  },

  receiveMessage: function(aMessage) {
    if (aMessage.name != this.messageName) {
      return;
    }

    if (!this._inited) {
      this._cachedMessages.push(aMessage);
      return;
    }

    switch(aMessage.data) {
      case "init":
        this.updateFromButton(aMessage.objects);
        break;
      case "mutation":
        this.updateFromMutation(aMessage.objects);
        break;
    }
  },

  init: function() {
    this._inited = true;

    while (this._cachedMessages.length) {
      this.receiveMessage(this._cachedMessages.shift());
    }
  },

  updateAttribute: function(aButton, aAttributeName) {
    if (aButton.hasAttribute(aAttributeName)) {
      let attributeVal = aButton.getAttribute(aAttributeName);
      switch (aAttributeName) {
        case "label":
          this.button.textContent = attributeVal;
          break;
        case "tooltiptext":
          this.button.setAttribute("title", attributeVal);
          break;
        default:
          this.button.setAttribute(aAttributeName, attributeVal);
          break;
      }
    } else {
      switch (aAttributeName) {
        case "label":
          this.button.textContent = "";
          break;
        case "tooltiptext":
          this.button.removeAttribute("title");
          break;
        default:
          this.button.removeAttribute(aAttributeName);
          break;
      }
    }
  },
  updateFromButton: function (aButton) {
    if (!this.button) {
      return;
    }

    let self = this;
    this.button.addEventListener('click', function(aEvt) {
      sendAsyncMessage(self.messageName, '', aEvt);

      Tracking.track({
        type: 'ntabsync',
        action: 'click',
        sid: 'in-content'
      });
    }, false, /** wantsUntrusted */false);

    for (let i = 0, l = this.attributes.length; i < l; i++) {
      this.updateAttribute(aButton, this.attributes[i]);
    }
  },
  updateFromMutation: function(aMutation) {
    let {target, attributeName} = aMutation;
    if (this.attributes.indexOf(attributeName) < 0) {
      return;
    }

    this.updateAttribute(target, attributeName);
  }
};

content.addEventListener('mozCNUtils:Tracking', function(aEvt) {
  Tracking.track(aEvt.detail);
}, true, true);

content.addEventListener(NTabSync.messageName, function(aEvt) {
  if (aEvt.detail && aEvt.detail.dir == 'content2fs') {
    sendAsyncMessage(NTabSync.messageName, aEvt.detail.data);
  }
}, true, true);

let relaySyncMessage = function(aEvt) {
  if (aEvt.data) {
    content.dispatchEvent(new content.CustomEvent(NTabSync.messageName, {
      detail: Cu.cloneInto({
        dir: 'fs2content',
        data: {
          id: aEvt.data.id,
          type: aEvt.data.type,
          state: aEvt.data.state
        }
      }, content)
    }));
  }
};

addMessageListener(NTabSync.messageName, relaySyncMessage);
addMessageListener(FxAccounts.messageName, FxAccounts);

content.addEventListener('DOMContentLoaded', function() {
  Launcher.init();
  DefaultBrowser.init();
  FxAccounts.init();
}, false);
content.addEventListener('unload', function() {
  removeMessageListener(NTabSync.messageName, relaySyncMessage);
  removeMessageListener(FxAccounts.messageName, FxAccounts);
}, false);
