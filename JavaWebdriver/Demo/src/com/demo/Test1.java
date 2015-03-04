package com.demo;

import java.io.File;
import java.io.IOException;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxProfile;
import org.openqa.selenium.firefox.internal.ProfilesIni;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testng.annotations.Test;

public class Test1 {
	
	//@Test
	public void test1(){
//		File file = new File("files/firebug-1.8.4.xpi");
//		FirefoxProfile profile = new FirefoxProfile();
//		try {
//			profile.addExtension(file);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
//		profile.setPreference("extensions.firebug.currentVersion","1.8.4");
//		ProfilesIni allProfiles = new ProfilesIni(); 
//		FirefoxProfile profile = allProfiles.getProfile("default");
//		File profileDir = new File("Profiles/raphlnmz.default");
//		FirefoxProfile profile = new FirefoxProfile(profileDir);
//		WebDriver driver = new FirefoxDriver(profile);
//		System.setProperty("webdriver.chrome.driver", "files/chromedriver.exe");
//		DesiredCapabilities capabilities = DesiredCapabilities.chrome();
//		capabilities.setCapability(capabilityName, value);
		
//		ChromeOptions options = new ChromeOptions();
//		File file = new File("User Data");
//		options.addArguments("user-data-dir="+file.getAbsolutePath());	
		
//		ChromeOptions options = new ChromeOptions();
//		options.addExtensions(new File("files/Video-Sorter-for-YouTube_v1.1.2.crx"));		
//		WebDriver driver = new ChromeDriver(options);
		
		System.setProperty("webdriver.ie.driver", "files/IEDriverServer64.exe");
		DesiredCapabilities capabilities = DesiredCapabilities.internetExplorer();
        capabilities.setCapability(InternetExplorerDriver.INTRODUCE_FLAKINESS_BY_IGNORING_SECURITY_DOMAINS, true);
        capabilities.setCapability("ignoreProtectedModeSettings",true);       
		WebDriver driver = new InternetExplorerDriver(capabilities);
		
		driver.navigate().to("http://www.baidu.com");
		driver.manage().window().maximize();
		driver.quit();
	}

}
