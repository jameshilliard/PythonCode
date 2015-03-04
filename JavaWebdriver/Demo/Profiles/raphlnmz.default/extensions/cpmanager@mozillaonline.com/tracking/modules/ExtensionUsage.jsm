var EXPORTED_SYMBOLS = ["ExtensionUsage"];

const { classes: Cc, interfaces: Ci, results: Cr, utils: Cu } = Components;

Cu.import("resource://gre/modules/XPCOMUtils.jsm");
XPCOMUtils.defineLazyModuleGetter(this, "CustomizableUI",
  "resource:///modules/CustomizableUI.jsm");
XPCOMUtils.defineLazyModuleGetter(this, "Services",
  "resource://gre/modules/Services.jsm");
XPCOMUtils.defineLazyModuleGetter(this, "Sqlite",
  "resource://gre/modules/Sqlite.jsm");

let DEBUG = true;
let LOG = function(aMsg) {
  if (DEBUG) {
    Services.console.logStringMessage("*** ExtensionUsage *** " + aMsg);
  }
};

let FILE = "mo-ext-usage.sqlite";
let ENFORCE_FOREIGN = "PRAGMA foreign_keys = ON;";

let CREATE_REGISTRY = "CREATE TABLE IF NOT EXISTS registry(" +
                      "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                      "usage TEXT NOT NULL CHECK(usage <> '') UNIQUE, " +
                      "type TEXT NOT NULL CHECK(type <> ''), " +
                      "addon TEXT NOT NULL CHECK(addon <> ''), " +
                      "since TEXT DEFAULT (date('now','localtime')));";
let DELETE_REGISTRY = "DELETE FROM registry WHERE usage = :usage;";
let INSERT_REGISTRY = "INSERT INTO registry(usage, type, addon) " +
                      "VALUES(:usage, :type, :addon);";
let SELECT_REGISTRY = "SELECT usage, type FROM registry;";

let CREATE_ACTIVITY = "CREATE TABLE IF NOT EXISTS activity(" +
                      "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                      "usage TEXT NOT NULL REFERENCES registry(usage) " +
                      "ON DELETE CASCADE, " +
                      "date TEXT DEFAULT (date('now','localtime')), " +
                      "count INTEGER DEFAULT 0, " +
                      "UNIQUE(usage, date));";
let DELETE_OBSOLETE = "DELETE FROM activity WHERE date <= " +
                      "(SELECT DISTINCT date FROM activity " +
                      "WHERE usage IN ('fx-startup', 'fx-midnight') " +
                      "ORDER BY date DESC LIMIT 1 OFFSET 90);";
let INSERT_ACTIVITY = "INSERT INTO activity(usage) VALUES(:usage);";
let INCREASE_ACTIVITY = "UPDATE activity SET count = count + 1 WHERE " +
                        "usage = :usage AND date = date('now')";
let INDEX_ACTIVITY_DATE = "CREATE INDEX IF NOT EXISTS index_activity_date " +
                          "ON activity(date);";

// table "state" is for customizations (e.g. prefs) implying button clicks
let CREATE_STATE = "CREATE TABLE IF NOT EXISTS state(" +
                   "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                   "key TEXT NOT NULL CHECK(key <> '') UNIQUE, " +
                   "value TEXT NOT NULL CHECK(value <> ''), " +
                   "usage TEXT NOT NULL REFERENCES registry(usage) " +
                   "ON DELETE CASCADE);";
let INSERT_STATE = "INSERT OR REPLACE INTO state(" +
                   "key, value, usage) " +
                   "VALUES(:key, :value, :usage);";
let INDEX_STATE_USAGE_VALUE = "CREATE INDEX IF NOT EXISTS " +
                              "index_state_usage_value ON state(usage, value);";

let SELECT_TRACK = "SELECT usage AS usage, sum(count) AS sum, " +
                   "EXISTS (SELECT value FROM state " +
                   "WHERE usage = r.usage AND value = 'true') AS related, " +
                   "(SELECT count(DISTINCT date) FROM activity " +
                   "WHERE usage IN ('fx-startup', 'fx-midnight') " +
                   "AND date >= since) AS fxusage " +
                   "FROM registry AS r LEFT JOIN activity " +
                   "USING(usage) GROUP BY usage;";

let reportError = function(aError) {
  if (aError.errors) {
    aError.errors.forEach(function(e) {
      if (e.result == Ci.mozIStorageError.CONSTRAINT) {
        LOG("Error " + e.result + ": " + e.message);
      } else {
        Cu.reportError("Error " + e.result + ": " + e.message);
      }
    });
  } else {
    Cu.reportError(aError);
  }
}

let ExtensionUsage = {
  DBConnection: null,
  dbVersion: 1,

  windowButtons: new Set(),

  monitorWindowButtons: function(aWindow) {
    let self = this;
    let clickHandler = function(aEvt) {
      let target = aEvt.target;
      // for widget from addon-sdk
      if (target.tagName.toLowerCase() == "img") {
        try {
          let iframe = aEvt.target.ownerDocument.defaultView.
            QueryInterface(Ci.nsIInterfaceRequestor).
            getInterface(Ci.nsIWebNavigation).
            QueryInterface(Ci.nsIDocShell).
            chromeEventHandler;
          target = iframe.parentNode;
        } catch(e) {}
      }
      LOG(target.tagName + "#" + target.id);

      if (target.id && self.windowButtons.has(target.id)) {
        self.increase(target.id);
      }
    };

    let toolbars = [];
    [
      CustomizableUI.AREA_NAVBAR,
      CustomizableUI.AREA_PANEL
    ].forEach(function(aId) {
      let toolbar = aWindow.document.getElementById(aId);
      toolbars.push(toolbar);

      let overflowTarget = toolbar.getAttribute("overflowtarget");
      if (overflowTarget) {
        toolbars.push(aWindow.document.getElementById(overflowTarget));
      }
    });

    toolbars.forEach(function(aToolbar) {
      if (aToolbar) {
        aToolbar.addEventListener("click", clickHandler, false);
      }
    });
    aWindow.addEventListener("unload", function() {
      toolbars.forEach(function(aToolbar) {
        if (aToolbar) {
          aToolbar.removeEventListener("click", clickHandler);
        }
      });
    }, false);
  },

  traverseRegistry: function(aOnRow) {
    this.DBConnection.executeCached(SELECT_REGISTRY, null, function(aRow) {
      aOnRow(aRow.getResultByName("usage"), aRow.getResultByName("type"));
    }).then(null, reportError);
  },

  register: function(aUsage, aType, aAddon) {
    let self = this;
    try {
      this.DBConnection.executeCached(INSERT_REGISTRY, {
        usage: aUsage,
        type: aType,
        addon: aAddon
      }).then(function() {
        self.addCriterion(aUsage, aType);
      }).then(null, reportError);
    } catch(e) {
      reportError(e);
    }
  },

  // TODO: figure out what to do when addon got uninstalled
  unregister: function(aUsage, aType) {
    let self = this;
    try {
      this.DBConnection.executeCached(DELETE_REGISTRY, {
        usage: aUsage
      }).then(function() {
        self.removeCriterion(aUsage, aType);
      }).then(null, reportError);
    } catch(e) {
      reportError(e);
    }
  },

  increase: function(aUsage, aDailyCb) {
    aDailyCb = aDailyCb || function() {};
    let self = this;
    try {
      let usage = {
        usage: aUsage
      };
      this.DBConnection.executeTransaction(function() {
        yield self.DBConnection.executeCached(INSERT_ACTIVITY, usage).
          then(aDailyCb, reportError);
        yield self.DBConnection.executeCached(INCREASE_ACTIVITY, usage);
      }).then(null, reportError);
    } catch(e) {
      reportError(e);
    }
  },

  setState: function(aKey, aValue, aUsage) {
    try {
      this.DBConnection.executeCached(INSERT_STATE, {
        key: aKey,
        value: aValue,
        usage: aUsage
      }).then(null, reportError);
    } catch(e) {
      reportError(e);
    }
  },

  track: function(aParams) {
    var tracker = Components.classes["@mozilla.com.cn/tracking;1"];
    if (!tracker || !tracker.getService().wrappedJSObject.ude) {
      return;
    }

    let qs = Object.keys(aParams).map(function(aKey) {
      return encodeURIComponent(aKey) + "=" + aParams[aKey];
    }).join("&");

    if (!qs) {
      return;
    }

    let url = "http://addons.g-fox.cn/usage.gif?" + qs;
    let xhr = Cc["@mozilla.org/xmlextras/xmlhttprequest;1"].
                createInstance(Ci.nsIXMLHttpRequest);
    xhr.onload = function() {
      LOG("Stats sent: " + url);
    };
    xhr.open("GET", url, true);
    xhr.send();
  },

  sendStats: function(aReason) {
    let self = this;
    try {
      let ret = {
        "reason": aReason.toString() || "unknown",
        "r": Math.random()
      };
      this.DBConnection.execute(SELECT_TRACK, null, function(aRow) {
        let sum = aRow.getResultByName("sum");
        let related = aRow.getResultByName("related");
        let fxusage = aRow.getResultByName("fxusage");
        if (sum || related || fxusage) {
          let item = [];
          item.push(sum || 0);
          item.push(related);
          item.push(fxusage);
          ret[aRow.getResultByName("usage")] = item.join(",");
        }
      }).then(function() {
        self.track(ret);
      }).then(null, reportError);
    } catch(e) {
      reportError(e);
    }
  },

  observe: function(aSubject, aTopic, aData) {
    switch (aTopic) {
      case "browser-delayed-startup-finished":
        this.monitorWindowButtons(aSubject);
        break;
    }
  },

  initMonitors: function() {
    Services.obs.addObserver(this, "browser-delayed-startup-finished", false);
  },

  addCriterion: function(aUsage, aType) {
    switch (aType) {
      case "window:button":
        this.windowButtons.add(aUsage);
        break;
    }
  },

  removeCriterion: function(aUsage, aType) {
    switch (aType) {
      case "window:button":
        this.windowButtons.delete(aUsage);
        break;
    }
  },

  initCriteria: function() {
    let addCriterion = this.addCriterion.bind(this);
    this.traverseRegistry(addCriterion);
  },

  // reference to timer to prevent it to be garbage collected
  _dailyTimer: null,
  setupTimer: function() {
    let self = this;
    let today = new Date();
    let date = new Date(today.getFullYear(),
      today.getMonth(), today.getDate() + 1, 0, 0, 1);

    this._dailyTimer = Cc["@mozilla.org/timer;1"].createInstance(Ci.nsITimer);
    this._dailyTimer.initWithCallback(function() {
      self.increase("fx-midnight");
      self.setupTimer();
    }, (date.getTime() - Date.now()), Ci.nsITimer.TYPE_ONE_SHOT);
  },

  init: function() {
    if (this.DBConnection) {
      return;
    }

    let self = this;
    Sqlite.openConnection({
      path: FILE
    }).then(function(aDBConnection) {
      self.DBConnection = aDBConnection;
      self.DBConnection.execute(ENFORCE_FOREIGN).then(function() {
        self.DBConnection.executeTransaction(function() {
          let version = self.DBConnection.getSchemaVersion ?
                        yield self.DBConnection.getSchemaVersion() :
                        self.DBConnection.schemaVersion.toString();

          switch(version) {
            // set up the latest schema if nothing existed yet
            case "0":
              yield self.DBConnection.execute(CREATE_REGISTRY);
              yield self.DBConnection.execute(CREATE_ACTIVITY);
              yield self.DBConnection.execute(CREATE_STATE);

              yield self.DBConnection.execute(INDEX_ACTIVITY_DATE);
              yield self.DBConnection.execute(INDEX_STATE_USAGE_VALUE);

              yield self.DBConnection.executeCached(INSERT_REGISTRY, {
                usage: "fx-startup",
                type: "fake",
                addon: "browser"
              }).then(null, reportError);
              yield self.DBConnection.executeCached(INSERT_REGISTRY, {
                usage: "fx-midnight",
                type: "fake",
                addon: "browser"
              }).then(null, reportError);

              if (self.DBConnection.setSchemaVersion) {
                yield self.DBConnection.setSchemaVersion(self.dbVersion);
              } else {
                self.DBConnection.schemaVersion = self.dbVersion;
              }
              break;
            /**
             case 1:
               possible data migration
               intentionally no break since version 1;
             case n + 1:
               possible data migration
               yield self.DBConnection.setSchemaVersion(self.dbVersion);
            **/
          }
        }).then(function() {
          self.increase("fx-startup", function() {
            self.DBConnection.execute(DELETE_OBSOLETE).then(function() {
              self.sendStats('fx-startup');
            }).then(null, reportError);
          });
          self.setupTimer();
          self.initCriteria();
        }).then(null, reportError);
      }).then(null, reportError);

      if (Sqlite.shutdown) {
        Sqlite.shutdown.addBlocker("ExtensionUsage: close db connection",
          () => self.DBConnection.close()
        );
      }
    }).then(null, reportError);

    this.initMonitors();
  }
};

ExtensionUsage.init();
