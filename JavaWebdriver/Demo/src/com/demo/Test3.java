package com.demo;

import java.util.List;
import java.util.Set;

import org.openqa.selenium.Alert;
import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;

public class Test3 {
	
	public WebDriver driver;
	
	public Test3(){
		driver = new FirefoxDriver();
		driver.manage().window().maximize();
	}
	
	public void close(){
		driver.close();
		driver.quit();
	}
	
	public void goTo(){
//		driver.get("http://www.baidu.com");		
//		driver.navigate().to("http://localhost:8080/demo.html");
		driver.navigate().to("file:///D://%E4%B8%AA%E4%BA%BA%E6%96%87%E6%A1%A3//demo.html");
	}
	
	public void testInput(){
//		driver.findElement(By.id("user")).sendKeys("test");
		WebElement element = driver.findElement(By.id("user"));
		element.sendKeys("test");
		element.clear();
		element.sendKeys("test");
		String text = element.getAttribute("value");
        System.out.println(text);
	}
	
	public void testLink(){
		WebElement element = driver.findElement(By.xpath("//div[@id='link']/a"));
		element.click();
		driver.navigate().back();
		String href = element.getAttribute("href");
		System.out.println(href);
		String className = element.getAttribute("class");
        System.out.println(className);
        String text = element.getText();
        System.out.println(text);
	}
	
	public void testSelect() {
        WebElement element = driver.findElement(By.cssSelector("select[name='select']"));
        Select select = new Select(element);
        select.selectByValue("opel");
//        select.selectByIndex(2);
//        select.selectByVisibleText("Opel");
        String text = select.getFirstSelectedOption().getText();
        System.out.println(text);
    }
	
	public void testRadioBox() {
        List<WebElement> elements = driver.findElements(By.name("identity"));
        elements.get(2).click();
        boolean select = elements.get(2).isSelected();
        System.out.println(select);
    }
	
	public void testCheckBox() {
        List<WebElement> elements = driver.findElements(By
                .xpath("//div[@id='checkbox']/input"));
        WebElement element = elements.get(2);
        element.click();
        boolean check = element.isSelected();
        System.out.println(check);
    }
	
	public void testButton() {
        WebElement element = driver.findElement(By.className("button"));
        element.click();
        boolean button = element.isEnabled();
        System.out.println(button);
    }
	 
	 public void testAlert() {
        WebElement element = driver.findElement(By.className("alert"));
        Actions action = new Actions(driver);
        action.click(element).perform();
        Alert alert = driver.switchTo().alert();        
        String text = alert.getText();
        System.out.println(text);
        alert.accept();
	 }
	 
	 public void testAction() {
        WebElement element = driver.findElement(By.className("over"));
        Actions action = new Actions(driver);
        action.moveToElement(element).perform();
        String text = driver.findElement(By.id("over")).getText();
        System.out.println(text);
    }
	 
	 public void testUpload() {
        WebElement element = driver.findElement(By.id("load"));        
        element.sendKeys("c://test.txt");        
    }
	 
	 public void testJavaScript(){
        JavascriptExecutor j = (JavascriptExecutor)driver;
        j.executeScript("alert('hellow rold!')");
        Alert alert = driver.switchTo().alert();
        String text = alert.getText();
        System.out.println(text);
        alert.accept();
    }
	 
	 public void testIframe(){
		 driver.switchTo().frame("aa");
//		 driver.switchTo().frame(0);
//		 WebElement iframe = driver.findElement(By.xpath("//iframe[@name='aa']"));
//		 driver.switchTo().frame(iframe);
		 driver.findElement(By.id("user")).sendKeys("test");
		 driver.switchTo().defaultContent();
	 }
	 
	 public void testMultiWindow() {
        WebElement element = driver.findElement(By.className("open"));
        element.click();
        Set<String> handles = driver.getWindowHandles();
        String handle = driver.getWindowHandle();
        handles.remove(driver.getWindowHandle());
        driver.switchTo().window(handles.iterator().next());        
        driver.close();    
        driver.switchTo().window(handle);
    }
	 
	 public void testWait() {
        WebElement element = driver.findElement(By.className("wait"));
        element.click();
//	        driver.manage().timeouts().implicitlyWait(12, TimeUnit.SECONDS);
        boolean wait = new WebDriverWait(driver, 10).until(new ExpectedCondition<Boolean>() {
                    public Boolean apply(WebDriver d) {
                        return d.findElement(By.className("red")).isDisplayed();
                    }
                });
        System.out.println(wait);
        System.out.println(driver.findElement(By.className("red")).getText());
    }

	
	public static void main(String[] args) {
		Test3 t = new Test3();
		t.goTo();
		t.testInput();
		t.testLink();
		t.testSelect();
		t.testRadioBox();
		t.testCheckBox();
		t.testButton();
		t.testAlert();
		t.testAction();
		t.testUpload();
		t.testJavaScript();
		t.testIframe();
		t.testMultiWindow();
		t.testWait();
		t.close();
	}

}
