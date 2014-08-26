*** Settings ***
Resource          ../../../Share_Resource.txt

*** Test Cases ***
00400111_Upgrade DUT to Code.test through CWMP (Without Traffic)
    #[Step 0][TR Set]    Firmware to Currernt
    TR_Firmware_Upgrade    %{U_CUSTOM_GA_FW_VER}
    #[Step 1][TR Set]    Modify following settings on DUT.
    #Modify Primary SSID with custom name    #Modify WiFi security with custom key
    TR_SPV_2G_SSID1_ANYWPA_BOTH_CUS_KEY
    #Enable Remote Telnet/SSH and set login credential
    TR_SPV_SSH_Enabled
    #[Step 2][Firmware Upgrade]
    TR_Firmware_Upgrade    %{U_CUSTOM_CURRENT_FW_TEST_VER}
    #[Step 3][Function Check]    DUT still can be connected correctly to WAN after firmware upgrade
    Fun_PingTest    %{U_CUSTOM_WAN_HOST}
    #[Step 4][TR Check]    All settings made at Step 1 can be carried over after firmware upgrade and function well.
    TR_GPV_Check    Device.WiFi.SSID.1.SSID=%{U_CUSTOM_SSID} string    Device.WiFi.AccessPoint.1.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK}
    TR_GPV_Check    Device.X_ACTIONTEC_COM_RemoteLogin.Enable=1 boolean    Device.X_ACTIONTEC_COM_RemoteLogin.Protocol=SSH string    Device.X_ACTIONTEC_COM_RemoteLogin.Username=%{U_DUT_TELNET_USER}

00400113_From GA FW to Current FW through CWMP (Without Traffic)
    #[Step 0][TR Set]    Firmware to GA
    TR_Firmware_Upgrade    %{U_CUSTOM_GA_FW_VER}
    #[Step 1][TR Set]    Modify following settings on DUT.
    #Modify Primary SSID with custom name    #Modify WiFi security with custom key
    TR_SPV_2G_SSID1_ANYWPA_BOTH_CUS_KEY
    #Enable Remote Telnet/SSH and set login credential
    TR_SPV_SSH_Enabled
    #[Step 2][Firmware Upgrade]
    TR_Firmware_Upgrade    %{U_CUSTOM_CURRENT_FW_TEST_VER}
    #[Step 3][Function Check]    DUT still can be connected correctly to WAN after firmware upgrade
    Fun_PingTest    %{U_CUSTOM_WAN_HOST}
    #[Step 4][TR Check]    All settings made at Step 1 can be carried over after firmware upgrade and function well.
    TR_GPV_Check    Device.WiFi.SSID.1.SSID=%{U_CUSTOM_SSID} string    Device.WiFi.AccessPoint.1.Security.ModeEnabled=WPA-WPA2-Personal    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPAEncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.X_ACTIONTEC_COM_WPA2EncryptionMode=TKIPandAESEncryption    Device.WiFi.AccessPoint.1.Security.PreSharedKey= %{U_WIRELESS_CUSTOM_WPAPSK}
    TR_GPV_Check    Device.X_ACTIONTEC_COM_RemoteLogin.Enable=1 boolean    Device.X_ACTIONTEC_COM_RemoteLogin.Protocol=SSH string    Device.X_ACTIONTEC_COM_RemoteLogin.Username=%{U_DUT_TELNET_USER}
