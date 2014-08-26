*** Settings ***
Suite Setup       TR_SPV_2G_SSID1_ANYWPA_BOTH_CUS_KEY
Test Teardown     TR_Disable_WiFi_2G_MAC_Authentication
Resource          ../../../../Share_Resource.txt

*** Test Cases ***
Wireless STA is in Deny List (Drop-Down List)
    [Tags]    prince
    #Begin Test
    #[Step 1][Fun Check]    Associate a Wireless STA with the SSID you are testing with correct key
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #[Step 2][TR Set]    Enable MAC Autentication on DUT and add the Wireless STA's MAC address to Deny Device List by selecting its MAC address from drop-down list.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC} string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC}
    #[Step 3][Fun Check]    The attempt to associate with the SSID must be rejected and the Wireless STA is unable to associate with DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}    postive=False
    #End Test

Wireless STA is in Allow List (Drop-Down List)
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Enable MAC Autentication on DUT and add the Wireless STA's MAC address to Allow Device List by selecting its MAC address from drop-down list.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC} string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC}
    #[Step 2][Fun Check]    The attempt to associate with the SSID must be rejected and the Wireless STA is unable to associate with DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #End Test

Wireless STA is NOT in Deny List
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Ensure that MAC Authentication feature has been enabled and there is at least 1 MAC address has been added in the Deny List for the SSID you are testing.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =11:22:33:44:55:66 string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =11:22:33:44:55:66
    #[Step 2][Fun Check]    The attempt to associate with the SSID must be rejected and the Wireless STA is unable to associate with DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #End Test

Wireless STA is NOT in Allow List
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Ensure that MAC Authentication feature has been enabled and there is at least 1 MAC address has been added in the Allow List for the SSID you are testing.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =11:22:33:44:55:66 string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =11:22:33:44:55:66
    #[Step 2][Fun Check]    The attempt to associate with the SSID must be rejected and the Wireless STA is unable to associate with DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}    positive=False
    #End Test

Disable MAC Authentication (Deny List)
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Ensure that a Wireless STA has been added to Deny List and the Wireless STA is unable to associate with the SSID you are testing.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC} string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =1    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC}
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}    postive=False
    #[Step 2][TR Set]    Disable MAC Authentication Feature
    TR_Disable_WiFi_2G_MAC_Authentication
    #[Step 3][Function Check]    The Wireless STA is able to associate with the SSID you are testing and can access WAN via DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}

Disable MAC Authentication (Allow List)
    [Tags]    prince
    #Begin Test
    #[Step 1][TR Set]    Ensure that a Wireless STA has been added to Allow List and the Wireless STA is able to associate with the SSID you are testing.
    TR_SPV    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC} string
    TR_GPV_Check    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Enabled =1 boolean    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_Deny_Policy =0    Device.WiFi.AccessPoint.1.ACL.X_ACTIONTEC_COM_ACL_MACList =%{U_WIRELESS_CARD_MAC}
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
    #[Step 2][TR Set]    Disable MAC Authentication Feature
    TR_Disable_WiFi_2G_MAC_Authentication
    #[Step 3][Function Check]    The Wireless STA is able to associate with the SSID you are testing and can access WAN via DUT
    #ConnectSSID    ssid=%{U_CUSTOM_SSID}    key=%{U_WIRELESS_CUSTOM_WPAPSK}    bssid=%{U_WIRELESS_2G_BSSID1}
