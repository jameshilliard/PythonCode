*** Settings ***
Resource          ../../../../../../Share_Resource.txt

*** Test Cases ***
02301654_Wireless Reset on Broadband Gateway
    #Begin Test
    #[Step 1] [Setup]    Change some wireless settings for example, SSID name, Security mode etc. on Broadband Gateway
    TRSPVOnGW    %{U_CUSTOM_UPGW_WLAN_NODE}.BeaconType=Basic string    %{U_CUSTOM_UPGW_WLAN_NODE}.BasicEncryptionModes=None string    %{U_CUSTOM_UPGW_WLAN_NODE}.SSID=%{U_WIRELESS_SSID1} string
    TRGPVOnGW    %{U_CUSTOM_UPGW_WLAN_NODE}.BeaconType=Basic string    %{U_CUSTOM_UPGW_WLAN_NODE}.BasicEncryptionModes=None    %{U_CUSTOM_UPGW_WLAN_NODE}.SSID=%{U_WIRELESS_SSID1}
    sleep     %{U_CUSTOM_ZERO_CONFIG_WAIT_TIME}
    #[Step 2][GUI Check]    The Security Configuration can be synchronized to DUT for SSID 1 (2.4GHz) correctly
    TR_GPV_Check    Device.WiFi.AccessPoint.1.Security.ModeEnabled=None
    #[Step 3][GUI Check]    The Security Configuration can be synchronized to DUT for SSID 1 (5GHz) correctly
    TR_GPV_Check    Device.WiFi.AccessPoint.5.Security.ModeEnabled=None
    #[Step 4][GUI Set]    Restore Wireless settings on Broadband Gateway
    #[Step 5][TR Check]    After wireless reset completed on the broadband gateway, wireless settings can be synchronized to DUT correctly
    TR_GPV_Check    Device.WiFi.AccessPoint.1.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPAEncryptionMode=AESEncryption    Device.WiFi.SSID.1.SSID=%{U_WIRELESS_SSID1}
    TR_GPV_Check    Device.WiFi.AccessPoint.5.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.5.Security.X_ACTIONTEC_COM_WPAEncryptionMode=AESEncryption    Device.WiFi.SSID.5.SSID=%{U_WIRELESS_SSID1}
    #[Step 6] [GUI Check]    WECB link on Broadband's Home page functions well.
    #[Step 7][Fun Check]    Wireless STA is able to associate to DUT in 2.4GHz frequency band with the SSID.
    ConnectSSID    ssid=%{U_WIRELESS_SSID1}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #[Step 8][Fun Check]    Wireless STA is able to associate to DUT in 5GHz frequency band with the SSID.
    ConnectSSID    ssid=%{U_WIRELESS_SSID1}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_5G_BSSID1}
    #End Test
