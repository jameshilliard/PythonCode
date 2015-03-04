pref("extensions.cehomepage.autoSetHomepage",false);
pref("extensions.cehomepage.keepsessions", 10);
pref("extensions.cehomepage.homepage", "chrome://cehomepage/locale/cehomepage.properties");
// the actual url in the about:cehome page.
pref("extensions.cehomepage.abouturl", "chrome://cehomepage/locale/cehomepage.properties");
// have to be set as an complex value, or about:home will be get as homepage url.
pref("browser.startup.homepage", "chrome://cehomepage/locale/cehomepage.properties");
// ATTENTION: make sure allowed_domain always starts with a dot
pref("extensions.cehomepage.allowed_domains", ".g-fox.cn, .firefoxchina.cn");
pref("extensions.cehomepage.autostartup", true);
//pref("browser.startup.homepage", "chrome://cehomepage/locale/cehomepage.properties");
//pref("browser.startup.homepage_reset", "chrome://cehomepage/locale/cehomepage.properties");
//pref("browser.startup.page", 1);
