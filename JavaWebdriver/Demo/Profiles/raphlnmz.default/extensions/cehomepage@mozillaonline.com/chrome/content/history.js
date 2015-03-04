(function() {

    var exposeReadOnly = function (obj) {
      if (null == obj) {
        return obj;
      }

      if (typeof obj !== "object") {
        return obj;
      }

      if (obj["__exposedProps__"]) {
        return obj;
      }

      // If the obj is a navite wrapper, can not modify the attribute.
      try {
        obj.__exposedProps__ = {};
      } catch (e) {
        return;
      }

      var exposedProps = obj.__exposedProps__;
      for (let i in obj) {
        if (i === "__exposedProps__") {
          continue;
        }

        if (i[0] === "_") {
          continue;
        }

        exposedProps[i] = "r";

        exposeReadOnly(obj[i]);
      }

      return obj;
    };

    var jsm = {};
    Cu.import('resource://ntab/utils.jsm', jsm);

    /**
     * Pref browser.startup.homepage have been set to "about:cehome" in the pref.js
     * And in distribution.ini, browser.startup.homepage is set to http://i.firefoxchina.cn.
     *
     * Before version 0.8.9, users' pref may have been set to about:cehome because of bug 151.
     * To make sure users' homepage could also be displayed normally even if the addon is disabled,
     * check pref to see if it is about:cehome, then restore the pref.
     */
    function resetHomepageIfPossible() {
        // in china edition, pref "browser.startup.homepage" is a locale string, has mimo type,
        // so must use  getLocale() other than get()
        // see in distribution.ini
        var homepage = prefs.getLocale("browser.startup.homepage", "");
        if ("about:cehome" == homepage) {
            prefs.reset("browser.startup.homepage");
        }
    }

    function cehomepage_autoSetHomepage() {
        var homepage = prefs.getLocale("extensions.cehomepage.homepage", "about:cehome");
        prefs.set("browser.startup.homepage", homepage);
    }

    function inject(host, win) {
        var cwin = win.wrappedJSObject;
        if (cwin['cehomepage']) {
            MOA.debug(['injected']);
            return;
        }
        var allowed_domains = prefs.get('extensions.cehomepage.allowed_domains', '').split(',');

        // Polyfill from http://mzl.la/1hiG2Iv
        function endsWith(fullString, searchString, position) {
            position = position || fullString.length;
            position = position - searchString.length;
            var lastIndex = fullString.lastIndexOf(searchString);
            return lastIndex !== -1 && lastIndex === position;
        }

        if (!allowed_domains.some(function(allowed_domain) {
            allowed_domain = allowed_domain.trim().toLowerCase();
            return (allowed_domain[0] === '.') && endsWith(host, allowed_domain);
        })) {
            MOA.debug(['cehomepage deny', host]);
            return;
        }

        MOA.debug(['cehomepage inject', host]);
        var cehomepage = {};
        homepage.init(cehomepage);
        frequent.init(cehomepage);
        last.init(cehomepage);
        sessionStore.init(cehomepage);
        if (cwin['do_history']) {
            cwin.do_history.call(cwin);
        }
        try {
            Cu.import("resource://gre/modules/PrivateBrowsingUtils.jsm");
            cehomepage['inPrivateMode'] = PrivateBrowsingUtils.isWindowPrivate(window);
        } catch(e) {
            try {
                var inPrivateBrowsing = Cc["@mozilla.org/privatebrowsing;1"].
                    getService(Ci.nsIPrivateBrowsingService).
                    privateBrowsingEnabled;
                cehomepage['inPrivateMode'] = inPrivateBrowsing;
            } catch(e) {
                // no private browsing support, do nothing
            }
        }
        cwin['cehomepage'] = exposeReadOnly(cehomepage);

    }

    var prefs = {
        branch: Cc['@mozilla.org/preferences-service;1'].getService(Ci.nsIPrefBranch2),
        get: function(k, v) {
            return Application.prefs.getValue(k, v);
        },
        getLocale: function(k, v) {
            try {
                // If pref is not an complex value, an exception will be thrown.
                return this.branch.getComplexValue(k, Ci.nsIPrefLocalizedString).data || v;
            } catch (e) {
                return this.get(k, v);
            }
        },
        set: function(k, v) {
            Application.prefs.setValue(k, v);
        },
        setLocale: function(k, v) {
            var pls = Cc['@mozilla.org/pref-localizedstring;1'].createInstance(Ci.nsIPrefLocalizedString);
            pls.data = v;
            this.branch.setComplexValue(k, Ci.nsIPrefLocalizedString, pls);
        },
        changed: function(k) {
            return this.branch.prefHasUserValue(k);
        },
        reset: function(k) {
            try {
                this.branch.clearUserPref(k);
            } catch (ex) {
                MOA.debug(['clearUserPref', k, ex]);
            }
        }
    };

    var homepage = {
        init: function(cehp) {
            var me = this;
            cehp['startup'] = {
                homepage: function() {
                    return me.homepage();
                },
                homepage_changed: function() {
                    return me.homepage_changed();
                },
                page: function() {
                    return me.page();
                },
                page_changed: function() {
                    return me.page_changed();
                },
                cehomepage: function() {
                    return me.cehomepage();
                },
                autostart: function(flag) {
                    return me.autostart(flag);
                },
                channelid: function() {
                    return me.channelid();
                },
                setHome: function(url) {
                    if (url != null && url != "" && url.indexOf("http://") == 0) {
                        prefs.set('browser.startup.homepage', url);
                        prefs.set('browser.startup.page', 1);
                    } else {
                        me.reset();
                    }
                }
            };
        },
        reset: function() {
            prefs.set('browser.startup.homepage', this.cehomepage());
            prefs.set('browser.startup.page', 1);
        },
        homepage: function() {
            var hp = prefs.getLocale('browser.startup.homepage', 'about:blank');
            return hp;
        },
        homepage_changed: function() {
            return prefs.changed('browser.startup.homepage') && this.homepage() != this.cehomepage();
        },
        page: function() {
            return prefs.get('browser.startup.page', 1);
        },
        page_changed: function() {
            return prefs.changed('browser.startup.page') && this.page() == 1;
        },
        cehomepage: function() {
            return prefs.get('extensions.cehomepage.homepage', 'http://i.firefoxchina.cn');
        },
        autostart: function(flag) {
            var ori = prefs.get('extensions.cehomepage.autostartup', true);
            if (typeof flag != 'undefined') {
                prefs.set('extensions.cehomepage.autostartup', flag);
            }
            return ori;
        },
        channelid: function() {
            return prefs.get("app.chinaedition.channel","www.firefox.com.cn");
        }
    };

    var sessionStore = {
        init: function(cehp) {
            var self = this;
            cehp['sessionStore'] = {
                get canRestoreLastSession() {
                    return self.canRestoreLastSession();
                },

                restoreLastSession: function() {
                    return self.restoreLastSession();
                }
            };
        },

        canRestoreLastSession: function() {
            let ss = Cc["@mozilla.org/browser/sessionstore;1"].getService(Ci.nsISessionStore);
            return ss.canRestoreLastSession;
        },

        restoreLastSession: function() {
            let ss = Cc["@mozilla.org/browser/sessionstore;1"].getService(Ci.nsISessionStore);
            if (ss.canRestoreLastSession) {
                ss.restoreLastSession();
            }
        }
    };

    var history = {
        dboptions: null,
        dbquery: null,
        db: null,
        name: 'none',
        needsDeduplication: false,
        order: Ci.nsINavHistoryQueryOptions.SORT_BY_NONE,

        init: function(cehp) {
            this.dboptions = PlacesUtils.history.getNewQueryOptions();
            this.dboptions.sortingMode = this.order;

            this.dbquery = PlacesUtils.history.getNewQuery();
            this.db = PlacesUtils.history.QueryInterface(Ci.nsPIPlacesDatabase);

            var me = this;
            cehp[this.name] = {
                query: function(n) {
                    return me.query(n);
                },
                queryAsync: function(n, callback) {
                    return me.queryAsync(n, callback);
                },
                remove: function(uri) {
                    return me.remove(uri);
                }
            };
        },
        query: function(n) {
            this.dboptions.maxResults = (n || 8) + 16;

            var dbResults = this.db.executeQuery(this.dbquery, this.dboptions).root;

            dbResults.containerOpen = true;
            var count = dbResults.childCount;
            var deduplication = {};
            var results = [];
            for (var i = 0; i < count; i++) {
                if (results.length >= (n || 8) + 8) {
                    break;
                }

                var result = dbResults.getChild(i);

                var title = result.title;

                if (this.needsDeduplication) {
                    if (deduplication[title]) {
                        continue;
                    }
                    deduplication[title] = 1;
                }

                results.push({
                    title: title,
                    url: result.uri,
                    uri: result.uri
                });
            }
            dbResults.containerOpen = false;

            return exposeReadOnly(results);
        },
        queryAsync: function(aMaxResults, aCallback) {
            this.dboptions.maxResults = (aMaxResults || 8) + 16;

            let deduplication = {};
            let links = [];
            let self = this;
            let callback = {
                handleResult: function (aResultSet) {
                    let row;

                    while (row = aResultSet.getNextRow()) {
                        if (links.length >= (aMaxResults || 8) + 8) {
                            break;
                        }

                        let uri = row.getResultByIndex(1);
                        let title = row.getResultByIndex(2);

                        if (self.needsDeduplication) {
                            if (deduplication[title]) {
                                continue;
                            }
                            deduplication[title] = 1;
                        }

                        links.push({uri: uri, url:uri, title: title});
                    }
                },

                handleError: function (aError) {
                    aCallback(exposeReadOnly([]));
                },

                handleCompletion: function (aReason) {
                    aCallback(exposeReadOnly(links));
                }
            };

            this.db.asyncExecuteLegacyQueries([this.dbquery], 1, this.dboptions, callback);
        },
        remove: function(uri) {
            PlacesUtils.bhistory.removePage(this.uri(uri));
        },
        uri: function(spec) {
            return Cc['@mozilla.org/network/io-service;1'].getService(Ci.nsIIOService).newURI(spec, null, null);
        }
    };


    var frequent = Object.create(history, {
        name: {
            value: 'frequent'
        },
        order: {
            value: Ci.nsINavHistoryQueryOptions.SORT_BY_FRECENCY_DESCENDING
        }
    });
    var last = Object.create(history, {
        name: {
            value: 'last'
        },
        needsDeduplication: {
            value: true
        },
        order: {
            value: Ci.nsINavHistoryQueryOptions.SORT_BY_DATE_DESCENDING
        }
    });


    var addonlistener = {
        onUninstalling: function (addon) {
            cancelAboutProtocol(addon);
        },

        onDisabling: function (addon) {
            cancelAboutProtocol(addon);
        },

        onOperationCancelled: function(addon) {
            if(addon.id == "cehomepage@mozillaonline.com") {
                var homepage = prefs.getLocale("browser.startup.homepage", "");
                var abouturl = prefs.getLocale("extensions.cehomepage.abouturl", "http://i.firefoxchina.cn/");
                var urls = homepage.split("|");
                for (var i = 0; i < urls.length; i++){
                    urls[i] = urls[i].trim() == abouturl ? "about:cehome" : urls[i].trim();
                }
                homepage = urls.join("|");
                prefs.set("browser.startup.homepage", homepage);
            }
        }
    };

    function cancelAboutProtocol(addon) {
        if(addon.id == "cehomepage@mozillaonline.com") {
            var homepage = prefs.getLocale("browser.startup.homepage", "");
            var abouturl = prefs.getLocale("extensions.cehomepage.abouturl", "http://i.firefoxchina.cn/");
            homepage = homepage.replace(/about:cehome/ig, abouturl);
            prefs.set("browser.startup.homepage", homepage);
            for (var j = 0; j < gBrowser.tabs.length; j++) {
                if (gBrowser.getBrowserAtIndex(j).contentWindow.document.location == "about:cehome") {
                    gBrowser.getBrowserAtIndex(j).contentWindow.document.location = abouturl;
                }
            }
        }
    }

    window.addEventListener('load', function() {
        window.setTimeout(function(evt) {
            resetHomepageIfPossible();

            // the following lines added for z.g-fox.cn, on first install of the addon, set z.g-fox.cn to homepage
            var autoSetHomepage = prefs.get("extensions.cehomepage.autoSetHomepage", false);
            if (autoSetHomepage) {
                if (Application.extensions && Application.extensions.get("cehomepage@mozillaonline.com").firstRun) {
                    cehomepage_autoSetHomepage();
                } else if (Application.getExtensions) {
                    // Application.extensions is obsolete in Gecko 2.0
                    Application.getExtensions(function(exts) {
                        if (exts.get("cehomepage@mozillaonline.com").firstRun) {
                            cehomepage_autoSetHomepage();
                        }
                    });
                }
            }

            /**
             * The distribution.ini of the old users may still remians the cehomepage pref as "about:cehome"
             * Still need to keep the addon listener.
             */
            AddonManager.addAddonListener(addonlistener);
            window.addEventListener('unload', function(evt) {
                AddonManager.removeAddonListener(addonlistener);
            }, false);
        }, 10);

        // Can not put the logic below in the timeout function.
        // Or the home page can not get the injected object in the very beginning, e.g. the very first run after profile is created.
        document.getElementById('appcontent').addEventListener("DOMContentLoaded", function(evt) {
            if (!evt.originalTarget instanceof HTMLDocument) {
                return;
            }

            try {
                var view = evt.originalTarget.defaultView;
                if (view.top == view || view.top == view.parent) {
                    MOA.debug(['inject', view.location.host.toLowerCase()]);
                    inject(view.location.host.toLowerCase(), view);
                }
            } catch (e) {
                MOA.debug('Error occurs when injecting.');
            }
        }, false);
    }, false);
}());
