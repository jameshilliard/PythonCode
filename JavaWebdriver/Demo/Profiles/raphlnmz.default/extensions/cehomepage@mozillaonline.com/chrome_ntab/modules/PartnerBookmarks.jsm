var EXPORTED_SYMBOLS = ['PartnerBookmarks'];

const { classes: Cc, interfaces: Ci, results: Cr, utils: Cu } = Components;

Cu.import("resource://gre/modules/XPCOMUtils.jsm");
if (XPCOMUtils.hasOwnProperty('defineLazyModuleGetter')) {
  XPCOMUtils.defineLazyModuleGetter(this, "PlacesUtils",
    "resource://gre/modules/PlacesUtils.jsm");
  XPCOMUtils.defineLazyModuleGetter(this, "Services",
    "resource://gre/modules/Services.jsm");
  XPCOMUtils.defineLazyModuleGetter(this, "Tracking",
    "resource://ntab/Tracking.jsm");
} else {
  Cu.import('resource://gre/modules/PlacesUtils.jsm');
  Cu.import('resource://gre/modules/Services.jsm');
  Cu.import('resource://ntab/Tracking.jsm');
}

let LOG = function(m) Services.console.logStringMessage(m);

let PartnerBookmarks = {
  get fisvc() {
    delete this.fisvc;
    return this.fisvc = Cc['@mozilla.org/browser/favicon-service;1'].
      getService(Ci.mozIAsyncFavicons || Ci.nsIFaviconService);
  },

  get prefs() {
    let branch = Services.prefs.getBranch('moa.partnerbookmark.');
    delete this.prefs;
    return this.prefs = branch;
  },

  get verifier() {
    delete this.verifier;
    return this.verifier = Cc["@mozilla.org/security/datasignatureverifier;1"].
      getService(Ci.nsIDataSignatureVerifier);
  },

  get key() {
    delete this.key;
    return this.key = this._getCharPref('key', '');
  },

  get updateUrl() {
    delete this.updateUrl;
    return this.updateUrl = 'http://bookmarks.firefoxchina.cn/bookmarks/updates.json';
  },

  _getCharPref: function(aPrefKey, aDefault) {
    let ret = aDefault;
    try {
      ret = this.prefs.getCharPref(aPrefKey);
    } catch(e) {}
    return ret;
  },

  _fetch: function(aUrl, aCallback) {
    if (!aUrl) {
      return;
    }
    let xhr = Cc["@mozilla.org/xmlextras/xmlhttprequest;1"]
                .createInstance(Ci.nsIXMLHttpRequest);
    xhr.open('GET', aUrl, true);
    xhr.onload = function(evt) {
      if (xhr.status == 200) {
        let data = JSON.parse(xhr.responseText);
        aCallback(data);
      }
    };
    xhr.onerror = function(evt) {};
    xhr.send();
  },

  _validate: function(aData) {
    try {
      let data = aData.data;
      let signature = aData.signature;
      return this.verifier.verifyData(data, signature, this.key);
    } catch(e) {
      LOG(e);
      return false;
    }
  },

  _keywordsForBookmarks: {
    // predefined (excluding those w/o querystrings?)
    'http://www.baidu.com/index.php?tn=monline_5_dg': 'mozcn:baidu:home',
    'http://www.amazon.cn/?source=Mozilla': 'mozcn:amazoncn:home',
    'http://www.vancl.com/?source=mozilla': 'mozcn:vancl:home',
    'http://r.union.meituan.com/url/visit/?a=1&key=yKmOefsJ5QiYS98RvpLzMN2qxT7BFhr4&url=http://www.meituan.com': 'mozcn:meituan:union',
    'http://www.hao123.com/?tn=12092018_12_hao_pg': 'mozcn:hao123:home',
    'http://youxi.baidu.com/yxpm/pm.jsp?pid=11016500091_877110': 'mozcn:baidu:youxi',

    // jd
    'http://click.union.360buy.com/JdClick/?unionId=206&siteId=1&to=http://www.360buy.com/': 'mozcn:jd:union',
    'http://click.union.360buy.com/JdClick/?unionId=316&siteId=21946&to=http://www.360buy.com': 'mozcn:jd:union',
    'http://click.union.360buy.com/JdClick/?unionId=20&siteId=439040_test_&to=http://www.360buy.com': 'mozcn:jd:union',

    // taobao (legacy)
    'http://click.mz.simba.taobao.com/rd?w=mmp4ptest&f=http%3A%2F%2Fwww.taobao.com%2Fgo%2Fchn%2Ftbk_channel%2Fonsale.php%3Fpid%3Dmm_28347190_2425761_9313996&k=e02915d8b8ad9603': 'mozcn:taobao:legacy',
    'http://redirect.simba.taobao.com/rd?c=un&w=channel&f=http%3A%2F%2Fwww.taobao.com%2Fgo%2Fchn%2Ftbk_channel%2Fonsale.php%3Fpid%3Dmm_28347190_2425761_9313997%26unid%3D&k=e02915d8b8ad9603&p=mm_28347190_2425761_9313997': 'mozcn:taobao:legacy',
    'http://redirect.simba.taobao.com/rd?c=un&w=channel&f=http%3A%2F%2Fwww.taobao.com%2Fgo%2Fchn%2Ftbk_channel%2Fonsale.php%3Fpid%3Dmm_28347190_2425761_13466329%26unid%3D&k=e02915d8b8ad9603&p=mm_28347190_2425761_13466329': 'mozcn:taobao:legacy',

    // tmall (legacy)
    'http://www.tmall.com/go/chn/tbk_channel/tmall_new.php?pid=mm_28347190_2425761_9313996&eventid=101334': 'mozcn:tmall:legacy',

    // weibo
    'http://weibo.com/?c=spr_web_sq_firefox_weibo_t001': 'mozcn:weibo:home',

    // yhd
    'http://www.yihaodian.com/product/index.do?merchant=1&tracker_u=1787&tracker_type=1&uid=433588_test_': 'mozcn:yhd:home',
    'http://www.yihaodian.com/?tracker_u=10977119545': 'mozcn:yhd:home',

    // taobao
    'http://www.taobao.com/go/chn/tbk_channel/onsale.php?pid=mm_28347190_2425761_13730658&eventid=101329': 'mozcn:toolbar:taobao',

    // tmall
    'http://s.click.taobao.com/t_9?p=mm_28347190_2425761_13676372&l=http%3A%2F%2Fmall.taobao.com%2F': 'mozcn:toolbar:tmall',
    'http://s.click.taobao.com/t?e=zGU34CA7K%2BPkqB05%2Bm7rfGGjlY60oHcc7bkKOQYmIX0uNLK1pwv%2BifTaqFIrn1w%2FakplTBnP3D56LgXgufuIPG%2FcBYvSdiC2vkuCKsBVr8VLhdXwLQ%3D%3D': 'mozcn:toolbar:tmall',
    'http://s.click.taobao.com/t_9?p=mm_28347190_2425761_14472249&l=http%3A%2F%2Fmall.taobao.com%2F': 'mozcn:toolbar:tmall',
    'http://s.click.taobao.com/t?e=m%3D2%26s%3DGEWeb2k8yoQcQipKwQzePCperVdZeJviK7Vc7tFgwiFRAdhuF14FMXq0KRRmDoQot4hWD5k2kjNoVxuUFnM6iJG6UkagZE085UoOeRlV%2BcG%2Bh63zuUZMYYgaseAKBk0cDPtbhjM5VDw%3D': 'mozcn:toolbar:tmall',
    'http://s.click.taobao.com/t?e=m%3D2%26s%3D0XGYiwkvavMcQipKwQzePCperVdZeJviK7Vc7tFgwiFRAdhuF14FMagXItMrTZFp79%2FTFaMDK6RoVxuUFnM6iJG6UkagZE085UoOeRlV%2BcG%2Bh63zuUZMYYgaseAKBk0cLdkr8YvWKT4%3D': 'mozcn:toolbar:tmall',
    'http://s.click.taobao.com/t?e=m%3D2%26s%3DHLQ0nwFAGAUcQipKwQzePCperVdZeJviK7Vc7tFgwiFRAdhuF14FMfTDcs3PiqZXlovu%2FCElQOtoVxuUFnM6iJG6UkagZE085UoOeRlV%2BcG%2Bh63zuUZMYYgaseAKBk0cLdkr8YvWKT4%3D': 'mozcn:toolbar:tmall'
  },

  _backfillKeywords: function() {
    let urls = Object.keys(this._keywordsForBookmarks);

    let self = this;
    urls.forEach(function(aUrl) {
      let url = aUrl;
      let keyword = self._keywordsForBookmarks[url];
      let uri = Services.io.newURI(url, null, null);
      let bookmarks = PlacesUtils.bookmarks.getBookmarkIdsForURI(uri, {});
      for (let i = 0, l = bookmarks.length; i < l; i++) {
        PlacesUtils.bookmarks.setKeywordForBookmark(bookmarks[i], keyword);
      }
    });

    this.prefs.setIntPref('backfillversion', this._backfillVersion);
    this.prefs.clearUserPref('migration');
  },

  _tempFix: function() {
    this.prefs.setIntPref('tempfixversion', this._tempFixVersion);
  },

  _realUpdate: function(aUpdates, aSignature) {
    if (this._getCharPref('signature', '') == aSignature) {
      return;
    }

    let keywords = Object.keys(aUpdates);

    let self = this;
    keywords.forEach(function(aKeyword) {
      let uri = PlacesUtils.bookmarks.getURIForKeyword(aKeyword);
      if (!uri) {
        return;
      }

      let item = aUpdates[aKeyword];
      let bookmarks = PlacesUtils.bookmarks.getBookmarkIdsForURI(uri, {});
      for (let i = 0, l = bookmarks.length; i < l; i++) {
        let id = bookmarks[i];
        // DO NOT change bookmark with matched url but not expected keyword
        if (PlacesUtils.bookmarks.getKeywordForBookmark(id) == aKeyword) {
          if (item.uri) {
            let newUri = Services.io.newURI(item.uri, null, null);
            PlacesUtils.bookmarks.changeBookmarkURI(id, newUri);

            if (item.title) {
              PlacesUtils.bookmarks.setItemTitle(id, item.title);
            }
            if (item.favicon) {
              let faviconUri = Services.io.
                newURI("fake-favicon-uri:" + item.uri, null, null);
              self.fisvc.replaceFaviconDataFromDataURL(faviconUri,
                item.favicon, 0);
              self.fisvc.setAndFetchFaviconForPage(newUri, faviconUri, false,
                self.fisvc.FAVICON_LOAD_NON_PRIVATE);
            }
            if (item.keyword) {
              PlacesUtils.bookmarks.setKeywordForBookmark(id, item.keyword);
            }
          } else {
            /* an empty object could be used to remove bookmarks:
               ... "mozcn:***:***": {}, ... */
            PlacesUtils.bookmarks.removeItem(id);
          }
        }
      }
    });

    this.prefs.setCharPref('signature', aSignature);
  },

  update: function() {
    let self = this;
    this._fetch(this.updateUrl, function(aData) {
      if (self._validate(aData)) {
        self._realUpdate(JSON.parse(aData.data), aData.signature);
      }
    });
  },

  _inited: false,

  _backfillVersion: 1,

  _tempFixVersion: 1,

  init: function() {
    if (this._inited) {
      return;
    }
    this._inited = true;

    let backfillVersion = 0;
    try {
      // backfillversion was incorrectly set as bool pref in bug 1091
      if (this.prefs.getPrefType('backfillversion') == this.prefs.PREF_BOOL) {
        backfillVersion = this.prefs.getBoolPref('backfillversion') ? 1 : 0;
        this.prefs.clearUserPref('backfillversion');
        this.prefs.setIntPref('backfillversion', backfillVersion);
      } else {
        backfillVersion = this.prefs.getIntPref('backfillversion');
      }
    } catch(e) {}

    if (backfillVersion < this._backfillVersion) {
      this._backfillKeywords();
    }

    let tempFixVersion = 0;
    try {
      tempFixVersion = this.prefs.getIntPref('tempfixversion');
    } catch(e) {}

    if (tempFixVersion < this._tempFixVersion) {
      this._tempFix();
    }

    this.update();

    PlacesUtils.bookmarks.addObserver({
      onBeginUpdateBatch: function() {},
      onEndUpdateBatch: function() {},
      onItemAdded: function() {},
      onBeforeItemRemoved: function() {},
      onItemRemoved: function() {},
      onItemChanged: function() {},
      onItemVisited: function(aItemId, b, c, d, aURI, f, g, h) {
        let keyword = PlacesUtils.bookmarks.getKeywordForBookmark(aItemId);
        let prefix = 'mozcn:toolbar:';
        if (keyword && keyword.indexOf(prefix) == 0) {
          Tracking.track({
            type: 'bookmarks',
            action: 'click',
            sid: keyword.substring(prefix.length)
          });
        }
      },
      onItemMoved: function() {}
    }, false);
  },

  getUpdateTracking: function(aSlugs) {
    let ret = [];

    aSlugs.forEach(function(aSlug) {
      let keyword = 'mozcn:toolbar:' + aSlug;
      let uri = PlacesUtils.bookmarks.getURIForKeyword(keyword);
      if (!uri) {
        return;
      }

      ret.push(aSlug);
    })
    return ret.join(',') || 'false';
  }
};
