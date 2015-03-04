package com.test.bean;

import com.test.util.Log;
import com.test.util.ParseXml;

public class Config {
	
	public static String browser;
	
	public static int waitTime;
	
	/**
	 * static{}，这种用法请大家务必搞清楚，这代表在用到Config这个类时，这个static{}里面的内容会被执行一次，且只被执行一次，就算多
	 * 次用到Config类，也只执行一次，所以，这个static{]一般就在加载一些配置文件，也可以说类似于单例模式。
	 * Integer.valueOf()可以把一个String或者其它的对象变成一个Integer的对象。
	 */
	static{		
		ParseXml px = new ParseXml("config/config.xml");
		browser = px.getElementText("/config/browser");
		waitTime = Integer.valueOf(px.getElementText("/config/waitTime"));
	}
	
	public static void main(String[] args) {
		Log.logInfo(Config.browser);
		Log.logInfo(Config.waitTime);		
	}	
}
