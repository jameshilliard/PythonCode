package com.test.page;

import org.openqa.selenium.WebDriver;

import com.test.base.Page;

public class FirstPage extends Page{

	public FirstPage(WebDriver driver) {
		super(driver);		
	}
	
	/**
	 * 因为chromedriver2.13版本的在movetoelement上有BUG，在2.14版中会解决，所以这个脚本只在FIREFOX上运行
	 */
	public void linkToMobileList(){
		this.getAction().moveToElement(this.getElement("手机数码京东通信")).perform();
		this.getElement("手机品类入口").click();
	}

}
