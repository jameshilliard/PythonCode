*** Settings ***
Resource          ../../../Share_Resource.txt

*** Test Cases ***
00400111_Upgrade DUT to Code.test through CWMP (Without Traffic)
    TR_Firmware_Upgrade    sdfsdf
    #[Step 1][TR Set]    Modify following settings on DUT.
    #Modify Primary SSID with custom name    #Modify WiFi security with custom key
    TR_SPV_2G_SSID1_ANYWPA_BOTH_CUS_KEY
    #Enable Remote Telnet/SSH and set login credential
    TR_Enable_DUT_Local_SSH
    #[Step 2][Firmware Upgrade]
    TR_Firmware_Upgrade    %{U_CUSTOM_CURRENT_FW_TEST_VER}
