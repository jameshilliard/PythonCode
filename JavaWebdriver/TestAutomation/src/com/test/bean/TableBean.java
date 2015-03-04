package com.test.bean;

import com.test.util.Log;

public enum TableBean {
	USER_INFO("com.test.bean.UserInfo");
    
    private String value;
     
    private TableBean(String value){
        this.value = value;
    }
     
    public String getValue(){
        return value;
    }
    @Override
    public String toString() {
            return value;              
    }
     
    public static void main(String[] args){
       Log.logInfo(TableBean.USER_INFO);
    }
}
