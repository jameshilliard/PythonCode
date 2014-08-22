*** Settings ***
Resource          ../../../../Share_Resource.txt

*** Test Cases ***
Wireless STA is in Deny List (Drop-Down List)
    #Begin Test
    #[Step 1][TR Set]    Set Wireless security method for the primary SSID to WPA-WPA2 BOTH (TKIP+AES) and enter key.
    TR_SPV    Device.WiFi.SSID.1.SSID=%{U_CUSTOM_SSID} string    Device.WiFi.AccessPoint.1.Security.ModeEnabled=WPA-WPA2-Personal string    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption string    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption string    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK} string
    TR_GPV_Check    Device.WiFi.SSID.1.SSID=%{U_CUSTOM_SSID} string    Device.WiFi.AccessPoint.1.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK}
    #[Step 2][Fun Check]    Associate a Wireless STA with the SSID you are testing with correct key
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #[Step 3][TR Set]    Enable MAC Autentication on DUT and add the Wireless STA's MAC address to Deny Device List by selecting its MAC address from drop-down list.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC} string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC}
    #[Step 4][Fun Check]    The attempt to associate with the SSID must be rejected and the Wireless STA is unable to associate with DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}    postive=False
    #End Test
