package com.test.util;

public class Util {
	
	public static void sleep(int secs){
		try {
			Thread.sleep(secs*1000);
		} catch (InterruptedException e) {			
			e.printStackTrace();
		}
	}
	
}
