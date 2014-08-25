*** Settings ***
Resource          ../../../../../Share_Resource.txt

*** Test Cases ***
WPA-WPA2 BOTH (TKIP+AES)
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Set Wireless security method for the primary SSID to WPA-WPA2 BOTH (TKIP+AES) and enter key.
    TR_SPV    Device.WiFi.SSID.5.SSID=%{U_CUSTOM_SSID} string    Device.WiFi.AccessPoint.5.Security.ModeEnabled=WPA-WPA2-Personal string    Device.WiFi.AccessPoint.5.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption string    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption string    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK} string
    TR_GPV_Check    Device.WiFi.SSID.5.SSID=%{U_CUSTOM_SSID}    Device.WiFi.AccessPoint.5.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.5.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK}
    #[Step 2][Fun Check]    Have following Wireless STAs try to assosicate the SSID with the key you set.    Except STA #10 and STA #11, all other STA must not be able to associate with the SSID
    #    STA #1: No Security
    #    STA #2: WEP Open 40-bit (ASCII)
    #    STA #3: WEP Open 128-bit (ASCII)
    #    STA #4: WEP Open 40-bit (HEX)
    #    STA #5: WEP Open 128-bit (HEX)
    #    STA #6: WEP Shared 40-bit (ASCII)
    #    STA #7: WEP Shared 128-bit (ASCII)
    #    STA #8: WEP Shared 40-bit (HEX)
    #    STA #9: WEP Shared 128-bit (HEX)
    #    STA #10: WPA TKIP PSK (ASCII)
    #    STA #11: WPA2 AES-CCMP PSK (ASCII)
    #    STA #12: WPA TKIP (ASCII) Incorrect Key
    #    STA #13: WPA2 AES (ASCII) Incorrect Key
    #
    ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_5G_BSSID1}    type=WPA_TKIP
    ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_5G_BSSID1}    type=WPA2_AES
    ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WRONG_WPAPSK}    bssid=%{U_WIRELESS_5G_BSSID1}    type=WPA_TKIP    positive=False
    ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WRONG_WPAPSK}    bssid=%{U_WIRELESS_5G_BSSID1}    type=WPA2_AES    positive=False
    #End Test
