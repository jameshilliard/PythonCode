package com.test.testcases;

import java.util.Map;

import org.testng.annotations.Test;

import com.test.base.TestBase;
import com.test.util.Log;

public class Test1 extends TestBase{
	
	@Test(dataProvider="providerMethod")
	public void testLogin(Map<String, String> param){
		Log.logInfo(param.get("username"));
		Log.logInfo(param.get("password"));
		Log.logInfo(param.get("inputValue"));
		Log.logInfo(param.get("url"));
	}

}
