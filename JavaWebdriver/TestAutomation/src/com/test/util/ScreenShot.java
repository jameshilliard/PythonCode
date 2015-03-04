package com.test.util;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import org.apache.commons.io.FileUtils;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;

public class ScreenShot {
	public WebDriver driver;

	public ScreenShot(WebDriver driver) {
		this.driver = driver;
	}

	private void takeScreenshot(String screenPath) {
		try {
			File scrFile = ((TakesScreenshot) driver)
					.getScreenshotAs(OutputType.FILE);
			FileUtils.copyFile(scrFile, new File(screenPath));
		} catch (IOException e) {
			System.out.println("Screen shot error: " + screenPath);
		}
	}

	public void takeScreenshot() {
		String screenName = String.valueOf(new Date().getTime()) + ".jpg";
		File dir = new File("test-output/snapshot");
		if (!dir.exists())
			dir.mkdirs();
		String screenPath = dir.getAbsolutePath() + "/" + screenName;
		this.takeScreenshot(screenPath);		
	}
}
