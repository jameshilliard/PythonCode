package com.demo;

import org.testng.Assert;
import org.testng.annotations.Test;

public class Test4 {

	@Test
	public void testAssert1() {
		System.out.println("��ʼ����");
		Assert.assertEquals("1", "1", "�Ƚ��������Ƿ���ȣ�");
		System.out.println("��������");
	}

	@Test
	public void testAssert2() {
		System.out.println("��ʼ����");
		Assert.assertEquals(1, 2, "�Ƚ��������Ƿ���ȣ�");
		System.out.println("��������");		
		String[] string1 = { "1", "2" };
		String[] string3 = string1;
		String[] string4 = { "1", "2" };
		Assert.assertSame(string1,string3,"string1��string3����ͬ");
		Assert.assertSame(string1, string4, "string1��string4�����");
	}
	
	@Test
	public void testAssert3(){
		Assertion.flag = true;
		System.out.println("��ʼ����3");
		Assertion.verifyEquals(1, 2, "�Ƚ��������Ƿ���ȣ�");
		System.out.println("��������3");
		Assert.assertTrue(Assertion.flag);
	}

}
