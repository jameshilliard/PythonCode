*** Settings ***
Resource          ../../Share_Resource.txt

*** Test Cases ***
02301383_Wireless Channel Width Default Settings
    #The Wireless Channel Width setting (on the Basic Setup page) should be 20MHz by default for the 2.4G radio.
    TR_GPV_Check    Device.WiFi.Radio.1.OperatingChannelBandwidth=20MHz

02301384_The secondary SSID
    #Secondary SSID including 2.4GHz and 5GHz should be disabled by default
    TR_GPV_Check    Device.WiFi.Radio.2.Enable=Disabled
    TR_GPV_Check    Device.WiFi.Radio.6.Enable=Disabled

02301385_Wireless default Password Phrase setting
    #The default Password Phrase setting (on the Basic Setup page) should be a unique 10-character value and the same value for both the 2.4G and 5G radios
    TR_GPV_Check    Device.WiFi.AccessPoint.1.Security.PreSharedKey
    Comment    Get Length    ${rc}
