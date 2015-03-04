let EXPORTED_SYMBOLS = ["Frequent", "Session"];

const { classes: Cc, interfaces: Ci, utils: Cu } = Components;
Cu.import('resource://gre/modules/Services.jsm');
Cu.import('resource://gre/modules/PlacesUtils.jsm');

let prefixes = [
  /^http:\/\/i.firefoxchina.cn\/n(ew)?tab/,
  /^http:\/\/i.firefoxchina.cn\/parts\/google_rdr/,
  /^http:\/\/i.firefoxchina.cn\/redirect\/adblock/,
  /^http:\/\/i.firefoxchina.cn\/(redirect\/)?search/,
  /^http:\/\/i.g-fox.cn\/(rd|search)/,
  /^http:\/\/www5.1616.net\/q/
];

let Frequent = {
  needsDeduplication: false,
  order: Ci.nsINavHistoryQueryOptions.SORT_BY_FRECENCY_DESCENDING,

  query: function(aCallback, aLimit) {
    let options = PlacesUtils.history.getNewQueryOptions();
    options.maxResults = aLimit + 16;
    options.sortingMode = this.order;

    let deduplication = {};
    let links = [];
    let self = this;

    let callback = {
      handleResult: function (aResultSet) {
        let row;

        while (row = aResultSet.getNextRow()) {
          if (links.length >= aLimit) {
            break;
          }
          let url = row.getResultByIndex(1);
          let title = row.getResultByIndex(2);

          if (self.needsDeduplication) {
            if (deduplication[title]) {
              continue;
            }
            deduplication[title] = 1;
          }

          if (!prefixes.some(function(aPrefix) {
            return aPrefix.test(url);
          })) {
            links.push({url: url, title: title});
          }
        }
      },

      handleError: function (aError) {
        aCallback([]);
      },

      handleCompletion: function (aReason) {
        aCallback(links);
      }
    };

    let query = PlacesUtils.history.getNewQuery();
    let db = PlacesUtils.history.QueryInterface(Ci.nsPIPlacesDatabase);
    db.asyncExecuteLegacyQueries([query], 1, options, callback);
  },

  remove: function(aUrls) {
    let urls = [];
    aUrls.forEach(function(aUrl) {
      urls.push(Services.io.newURI(aUrl, null, null));
    });
    PlacesUtils.bhistory.removePages(urls, urls.length);
  }
};

let Session = Object.create(Frequent, {
  needsDeduplication: {
    value: true
  },
  order: {
    value: Ci.nsINavHistoryQueryOptions.SORT_BY_DATE_DESCENDING
  }
});
