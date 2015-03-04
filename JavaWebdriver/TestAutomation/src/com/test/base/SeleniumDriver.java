package com.test.base;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.ie.InternetExplorerDriver;
import org.openqa.selenium.remote.DesiredCapabilities;

import com.test.bean.Config;
import com.test.util.Log;

public class SeleniumDriver {
	
	private WebDriver driver;

	public WebDriver getDriver() {
		return driver;
	}	
	
	public SeleniumDriver() {
		this.initialDriver();
	}

	private void initialDriver(){
		if("firefox".equals(Config.browser)){
			driver = new FirefoxDriver();
		}else if("ie".equals(Config.browser)){
			System.setProperty("webdriver.ie.driver", "files/iedriver.exe");
			DesiredCapabilities capabilities = DesiredCapabilities.internetExplorer();
	        capabilities.setCapability(InternetExplorerDriver.INTRODUCE_FLAKINESS_BY_IGNORING_SECURITY_DOMAINS, true);
	        capabilities.setCapability("ignoreProtectedModeSettings",true);       
			driver = new InternetExplorerDriver(capabilities);
		}else if("chrome".equals(Config.browser)){
			System.setProperty("webdriver.chrome.driver", "files/chromedriver.exe");
			ChromeOptions options = new ChromeOptions();
			options.addArguments("--test-type");
			driver = new ChromeDriver(options);
		}else{
			Log.logInfo(Config.browser+" 的值不正确，请检查！");
		}
		driver.manage().window().maximize();
		driver.manage().timeouts().pageLoadTimeout(Config.waitTime, TimeUnit.SECONDS);	
	}	
	
	public static void main(String[] args) {
		SeleniumDriver selenium = new SeleniumDriver();
		WebDriver driver = selenium.getDriver();
		driver.navigate().to("http://www.baidu.com");
		driver.close();
		driver.quit();
	}
}
