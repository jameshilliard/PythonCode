package com.test.testcases;

import java.util.Map;

import org.testng.Assert;
import org.testng.annotations.Test;

import com.test.base.TestBase;
import com.test.page.FirstPage;
import com.test.page.MobileList;
import com.test.page.ProductPage;
import com.test.page.ShoppingCart;
import com.test.util.Assertion;
import com.test.util.Log;

public class Shopping extends TestBase{
	
	@Test(dataProvider="providerMethod")
	public void testShopping(Map<String, String> param){
		Assertion.flag = true;		
		this.goTo(param.get("url"));
		FirstPage fp = new FirstPage(driver);
		Log.logInfo("从首页进入手机搜索页面");
		fp.linkToMobileList();
		MobileList ml = new MobileList(driver);
		ml.getElement("商品筛选华为").click();
		ml.getElement("商品价格筛选").click();
		ml.getElement("商品颜色筛选").click();
		ml.getElement("商品类型筛选").click();
		ml.getElement("第一个商品").click();
		ml.switchWindowByIndex(1);
		ProductPage pp = new ProductPage(driver);
		String productName = pp.getElement("商品名称").getText();
		String productPrice = pp.getElement("商品价格").getText();
		String productUrl = driver.getCurrentUrl();
		int s = productUrl.lastIndexOf("/");
		int e = productUrl.lastIndexOf(".");	
		String[] sku = new String[]{productUrl.substring(s+1, e)};
		pp.getElement("加入购物车").click();
		pp.getElement("去购物车结算").click();
		ShoppingCart sc = new ShoppingCart(driver);
		Assertion.verifyEquals(true, productName.contains(sc.getElement("商品名称", sku).getText()));
		Assertion.verifyEquals(productPrice.substring(1),sc.getElement("商品价格", sku).getText().substring(1));
		Assertion.verifyEquals(true, sc.getElement("勾选商品", sku).isSelected());
		sc.getElement("删除商品",sku).click();
		sc.getElement("确定删除").click();
		sc.waitElementToBeNonDisplayed(sc.getElement("商品名称", sku));
		Assertion.verifyEquals(false, sc.isExist(sc.getElementNoWait("商品名称", sku)));		
		Assert.assertTrue(Assertion.flag);
	}	
	
}
