package com.demo.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

public class DemoPage extends Page{		

	public static By input = By.id("user");	
	public static By link = By.xpath("//div[@id='link']/a");
	public static By select = By.cssSelector("select[name='select']");
	public static By radio = By.name("identity");
	public static By check = By.xpath("//div[@id='checkbox']/input");
	public static By button = By.className("button");
	public static By alert = By.className("alert");
	public static By action = By.className("over");
	public static By upload = By.id("load");
	public static String iframe = "aa";
	public static By multiWin = By.className("open");
	public static By wait = By.className("wait");	
	
	public DemoPage(WebDriver driver) {
		super(driver);		
	}
	
	public void input(){
		WebElement element = this.getElement(input);
		element.sendKeys("test");
		element.clear();
		element.sendKeys("test");
		String text = element.getAttribute("value");
        System.out.println(text);
	}
}
