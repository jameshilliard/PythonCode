package com.demo.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.WebDriverWait;

public class Page {
	
	protected WebDriver driver;	
	
	public Page(WebDriver driver) {		
		this.driver = driver;
	}

	private boolean waitToDisplayed(final By key){
		boolean waitDisplayed = new WebDriverWait(driver, 10).until(new ExpectedCondition<Boolean>() {
            public Boolean apply(WebDriver d) {
                return d.findElement(key).isDisplayed();
            }
        });
		return waitDisplayed;
	}
	
	protected WebElement getElement(By key){
		WebElement element = null;
		if(this.waitToDisplayed(key)){
			element = driver.findElement(key);
		}
		return element;
	}	
}
