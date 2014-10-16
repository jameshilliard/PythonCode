package com.marschen.s01_e09_checkbox;

import java.util.zip.CheckedInputStream;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;


public class MainActivity extends Activity {
	private CheckBox  eatBox;
	private CheckBox  sleepBox;
	private CheckBox  dotaBox;
	
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        eatBox = (CheckBox)findViewById(R.id.eatId);
        sleepBox = (CheckBox)findViewById(R.id.sleepId);
        dotaBox = (CheckBox)findViewById(R.id.dotaId);
        OnBoxClickListener listener = new OnBoxClickListener();
        eatBox.setOnClickListener(listener);
        sleepBox.setOnClickListener(listener);
        dotaBox.setOnClickListener(listener);
        CheckBoxListener listener2 = new CheckBoxListener();
        eatBox.setOnCheckedChangeListener(listener2);
        sleepBox.setOnCheckedChangeListener(listener2);
        dotaBox.setOnCheckedChangeListener(listener2);
    }

    class CheckBoxListener implements OnCheckedChangeListener{

		@Override
		public void onCheckedChanged(CompoundButton buttonView,
				boolean isChecked) {
			// TODO Auto-generated method stub
			if(buttonView.getId() == R.id.eatId){
				System.out.println("eatBox");
			}
			else if(buttonView.getId() == R.id.sleepId){
				System.out.println("sleeepBox");
			}
			
			else if(buttonView.getId() == R.id.dotaId){
				System.out.println("dotaBox");
			}
			
			if(isChecked){
				System.out.println("is Checked");
			}
			else {
				System.out.println("is Unchecked");
			}
		}
    	
    }

    class OnBoxClickListener implements OnClickListener{
		@Override
		public void onClick(View view) {
			// TODO Auto-generated method stub
			view.getId();
			CheckBox box = (CheckBox)view;
			System.out.println("id=========>"+view.getId());
			if(view.getId() == R.id.eatId){
				System.out.println("eatBox");
				box.isChecked();
			}
			else if(view.getId() == R.id.sleepId){
				System.out.println("sleepBox");
			}
			else if(view.getId() == R.id.dotaId){
				System.out.println("dotaBox");
			}
			if(box.isChecked()){
				System.out.println("checkox is checked");
			}
			else{
			System.out.println("CheckBox is unchecked");
			}
			
		}
    	
    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
}