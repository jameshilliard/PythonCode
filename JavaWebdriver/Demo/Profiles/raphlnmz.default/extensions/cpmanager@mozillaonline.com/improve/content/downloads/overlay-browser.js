(function() {
var DL = {
  handleEvent: function DL__handleEvent(aEvent) {
    switch (aEvent.type) {
      case "load":
        this.init();
        break;
    }
  },
  init: function DL__init() {
    DownloadsViewItem.prototype.onProgressChange = function() {
      this._updateProgress();
      this._updateStatusLine();

      if (this.dataItem.state == Ci.nsIDownloadManager.DOWNLOAD_DOWNLOADING) {
        var status, newEstimatedSecondsLeft;
        [status, newEstimatedSecondsLeft] =
          DownloadUtils.getDownloadStatus(this.dataItem.currBytes,
                                          this.dataItem.maxBytes,
                                          this.dataItem.speed,
                                          this.lastEstimatedSecondsLeft);
        this._element.setAttribute("status", status);
      }
    }
  },
}
window.addEventListener('load' , DL, false);
})();
