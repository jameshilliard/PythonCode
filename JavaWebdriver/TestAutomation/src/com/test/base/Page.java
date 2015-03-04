package com.test.base;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;

public class Page extends Locator{
	
	public Page(WebDriver driver) {		
		super(driver);		
		this.setYamlFile(this.getClass().getSimpleName());
		this.getYamlFile();
	}
	
	public Actions getAction(){
		return new Actions(driver);
	}
	
	public void switchWindowByIndex(int index){
		Object[] handles = driver.getWindowHandles().toArray();
		if(index>handles.length){
			return;
		}
		driver.switchTo().window(handles[index].toString());
	}
	
	public boolean isExist(WebElement element){
		if(element==null){
			return false;
		}else{
			return true;
		}
	}
	
	/**
	 * 该方法为示例方法
	 */
	public void test(){
		driver.navigate().to("");
	}

}
