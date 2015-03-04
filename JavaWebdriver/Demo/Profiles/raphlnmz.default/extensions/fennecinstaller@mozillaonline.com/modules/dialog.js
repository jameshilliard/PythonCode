(function() {
  var init = function _init() {
    var dl_btn = document.getElementById("dl_btn");
    dl_btn.onclick = function() {
      if (!Key.Open(this, 'android')) {
        var evt = document.createEvent("CustomEvent");
        evt.initEvent("oneClickInstall", true, false);
        window.dispatchEvent(evt);
        return false;
      }
      return true;
    };

    var dl_pkg = document.getElementById("dl_pkg");
    dl_pkg.onclick = function() {
      var evt = document.createEvent("CustomEvent");
      evt.initEvent("downloadPackage", true, false);
      window.dispatchEvent(evt);
    };

    var acknowledge = document.getElementById("acknowledge");
    acknowledge.onclick = function() {
      var evt = document.createEvent("CustomEvent");
      evt.initEvent("acknowledge", true, false);
      window.dispatchEvent(evt);
    };
  };

  window.addEventListener('load', init, false);
})();
