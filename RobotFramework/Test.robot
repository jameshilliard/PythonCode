*** Settings ***
Library           Selenium2Library
Library           AppiumLibrary
Library           Collections
Library           MyLibrary

*** Test Cases ***
test
    Open Browser    http://www.baidu.com
    sleep    5
    Close All Browsers
    Mytest

Appium-Demo
    Comment    Open Application    http://localhost:4723/wd/hub    platformName=android    platformVersion=5.0.1    deviceName=nexus5    app=E:/AndroidCode/AndroidDemoProject.apk
    Open Application    http://localhost:4723/wd/hub    platformName=android    platformVersion=5.0.1    deviceName=nexus5    appPackage=com.android.settings    appActivity=Settings
    Comment    Wait Until Keyword Succeeds    2min    5sec    Element Should Be Visible    id=sh.calaba.demoproject:id/textView1
    Comment    Page Should Contain Element    id=sh.calaba.demoproject:id/textView1
    Comment    Click Element    id=sh.calaba.demoproject:id/editText1
    Comment    Input Text    id=sh.calaba.demoproject:id/editText1    wangshengshun
    Comment    Input Password    id=sh.calaba.demoproject:id/editText2    shun19860323
    Comment    Input Text    id=sh.calaba.demoproject:id/editText3    wangshengshundy@126.com
    Comment    Click Element    id=sh.calaba.demoproject:id/radioButton1
    Comment    Click Element    id=sh.calaba.demoproject:id/checkBox1
    Comment    Click Button    提交表单
    Comment    Capture Page Screenshot    E:/AndroidCode/appium-screenshot.png
    Comment    Close Application
    AppiumLibrary.Capture Page Screenshot
    Close Application

Appium-Demo-2
    Comment    Open Application    http://localhost:4723/wd/hub    platformName=android    platformVersion=5.0.1    deviceName=nexus5    app=E:/AndroidCode/AndroidDemoProject.apk
    Open Application    http://localhost:4723/wd/hub    platformName=android    platformVersion=5.0.1    deviceName=nexus5    appPackage=com.android.settings    appActivity=Settings
    Comment    Wait Until Keyword Succeeds    2min    5sec    Element Should Be Visible    id=sh.calaba.demoproject:id/textView1
    Comment    Page Should Contain Element    id=sh.calaba.demoproject:id/textView1
    Comment    Click Element    id=sh.calaba.demoproject:id/editText1
    Comment    Input Text    id=sh.calaba.demoproject:id/editText1    wangshengshun
    Comment    Input Password    id=sh.calaba.demoproject:id/editText2    shun19860323
    Comment    Input Text    id=sh.calaba.demoproject:id/editText3    wangshengshundy@126.com
    Comment    Click Element    id=sh.calaba.demoproject:id/radioButton1
    Comment    Click Element    id=sh.calaba.demoproject:id/checkBox1
    Comment    Click Button    提交表单
    Comment    Capture Page Screenshot    E:/AndroidCode/appium-screenshot.png
    Comment    Close Application
    AppiumLibrary.Capture Page Screenshot
    Close Application
