package com.demo;

import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

public class Test2 {
	
	@BeforeMethod
	public void setUp(){
		System.out.println("setUp method");
	}	
	
	@Test
	public void test2(){
		System.out.println("test2");
	}
	
	@Test
	public void test1(){
		System.out.println("test1");
	}
	
	
	
	@DataProvider
	public Object[][] dataProvider(){
		return new Object[][]{{"1"},{"2"}};
	}
	
	@Test(dataProvider="dataProvider")
	public void testData(String a){
		System.out.println(a);
	}
	
	@AfterMethod
	public void tearDown(){
		System.out.println("tearDown method");
	}
	
}
