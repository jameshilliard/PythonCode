package com.demo;

import org.testng.Assert;
import org.testng.annotations.Test;

public class Test4 {

	@Test
	public void testAssert1() {
		System.out.println("开始断言");
		Assert.assertEquals("1", "1", "比较两个数是否相等：");
		System.out.println("结束断言");
	}

	@Test
	public void testAssert2() {
		System.out.println("开始断言");
		Assert.assertEquals(1, 2, "比较两个数是否相等：");
		System.out.println("结束断言");		
		String[] string1 = { "1", "2" };
		String[] string3 = string1;
		String[] string4 = { "1", "2" };
		Assert.assertSame(string1,string3,"string1和string3不相同");
		Assert.assertSame(string1, string4, "string1和string4不相等");
	}
	
	@Test
	public void testAssert3(){
		Assertion.flag = true;
		System.out.println("开始断言3");
		Assertion.verifyEquals(1, 2, "比较两个数是否相等：");
		System.out.println("结束断言3");
		Assert.assertTrue(Assertion.flag);
	}

}
