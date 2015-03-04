package com.demo;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.annotations.Test;

public class Test5 {
	
	@Test
	public void testBaidu(){
		WebDriver driver = new FirefoxDriver();
		driver.manage().window().maximize();
		driver.navigate().to("http://www.baidu.com");
		ScreenShot ss = new ScreenShot(driver);
		ss.takeScreenshot();
		driver.close();
		driver.quit();
	}
	
}
