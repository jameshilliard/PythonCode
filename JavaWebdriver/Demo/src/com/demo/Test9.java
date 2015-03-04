package com.demo;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import com.demo.pages.DemoPage;

public class Test9 {
	
	private WebDriver driver;
	
	@BeforeClass
	public void setUp(){
		driver = new FirefoxDriver();
		driver.manage().window().maximize();
		driver.navigate().to("file:///D://%E4%B8%AA%E4%BA%BA%E6%96%87%E6%A1%A3//demo.html");
	}
	
	@Test
	public void testInput(){
		DemoPage dp = new DemoPage(driver);
		dp.input();
	}
	
	@AfterClass
	public void tearDown(){
		driver.close();
		driver.quit();
	}
	
}
