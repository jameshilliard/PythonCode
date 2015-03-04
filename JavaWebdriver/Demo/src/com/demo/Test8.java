package com.demo;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class Test8 {
	
	private WebDriver driver;
	
	@BeforeClass
	public void setUp(){
		driver = new FirefoxDriver();
		driver.navigate().to("file:///D://%E4%B8%AA%E4%BA%BA%E6%96%87%E6%A1%A3//demo.html");
	}
	
	@Test
	public void testInput(){
		WebElement element = driver.findElement(Test7.input);
		element.sendKeys("test");
		element.clear();
		element.sendKeys("test");
		String text = element.getAttribute("value");
        System.out.println(text);
	}
	
}
