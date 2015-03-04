nsPluginInstallerWizard.prototype.showPluginList = function () {
  var myPluginList = document.getElementById("pluginList");
  var hasPluginWithInstallerUI = false;

  // clear children
  for (var run = myPluginList.childNodes.length; run > 0; run--)
    myPluginList.removeChild(myPluginList.childNodes.item(run));

  this.pluginsToInstallNum = 0;

  for (var pluginInfoItem in this.mPluginInfoArray) {
    // [plugin image] [Plugin_Name Plugin_Version]

    var pluginInfo = this.mPluginInfoArray[pluginInfoItem];

    // create the checkbox
    var arr = pluginInfo.name.split(":")
    pluginInfo.name = arr[0];
    var description = arr[1];
    var myCheckbox = document.createElement("checkbox");
    myCheckbox.setAttribute("checked", "true");
    myCheckbox.setAttribute("oncommand", "gPluginInstaller.toggleInstallPlugin('" + pluginInfo.pid + "', this)");
    // XXXlocalize (nit)
    myCheckbox.setAttribute("label", pluginInfo.name + " " + (pluginInfo.version ? pluginInfo.version : ""));
    myCheckbox.setAttribute("src", pluginInfo.IconUrl);
    myCheckbox.setAttribute("style", "font-size:larger;");

    myPluginList.appendChild(myCheckbox);
    if (description) {
      var myLabel = document.createElement("label");
      myLabel.setAttribute("value", description);
      myLabel.setAttribute("style", "margin-left: 30px;");
      myPluginList.appendChild(myLabel);
    }

    if (pluginInfo.InstallerShowsUI == "true")
      hasPluginWithInstallerUI = true;

    // keep a running count of plugins the user wants to install
    this.pluginsToInstallNum++;
  }

  if (hasPluginWithInstallerUI)
    document.getElementById("installerUI").hidden = false;

  this.canAdvance(true);
  this.canRewind(false);
}
