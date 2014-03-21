package com.example.taxipricecaculator;

import android.os.Bundle;
import android.app.Activity;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.view.Menu;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;

public class TaxtPriceCaculator extends Activity {
	private final int BASE_MILES = 3;
	private final int BASE_MILES_LONG = 10;
	private final int BASE_PRICE = 14;
	private static final float PRICE_PER = (float) 2.4;
	private static final float PRICE_PER_EXTRA = (float) 3.6;
	
	private final int BASE_PRICE_NIGHT = 18;
	private static final float PRICE_PER_NIGHT = (float) 3.1;
	private static final float PRICE_PER_EXTRA_NIGHT = (float) 4.7;
	
	private EditText mMilesInput;
	private Button mDisplayPrice;
	private Switch mAddFeeMode;
	private TextView mIntroduction;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_taxt_price_caculator);
		findViewById();
		addListener();
		init();
	}

	private void init() {
		mIntroduction.setMovementMethod(ScrollingMovementMethod.getInstance());
	}

	private void findViewById() {
		mMilesInput = (EditText) this.findViewById(R.id.mileage_input);
		mDisplayPrice = (Button) this.findViewById(R.id.price_display);
		mAddFeeMode = (Switch) this.findViewById(R.id.switch_day_night_modes);
		mIntroduction = (TextView) this.findViewById(R.id.info);
	}

	private void addListener() {
		// TODO Auto-generated method stub
		mMilesInput.addTextChangedListener(new TextWatcher(){

			@Override
			public void afterTextChanged(Editable s) {
				// TODO Auto-generated method stub
				
				float miles = 0;
				try {
					miles = Float.parseFloat(s.toString().trim());
				} catch (NumberFormatException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				mDisplayPrice.setText(CaculateFee(miles, mAddFeeMode.isChecked()) + "");
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				// TODO Auto-generated method stub
				
			}
			
		});
		
		mAddFeeMode.setOnCheckedChangeListener(new OnCheckedChangeListener(){

			@Override
			public void onCheckedChanged(CompoundButton buttonView,
					boolean isChecked) {
				int miles = 0;
				try {
					miles = Integer.parseInt(mMilesInput.getText().toString().trim());
				} catch (NumberFormatException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				mDisplayPrice.setText(CaculateFee(miles, mAddFeeMode.isChecked()) + "");
				
			}
			
		});
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	private float CaculateFee(float miles, boolean night_mode){
		if(!night_mode){
			if(miles < BASE_MILES){
				return BASE_PRICE;
			}else if (miles > BASE_MILES && miles <= BASE_MILES_LONG){
				return (BASE_PRICE + (miles - BASE_MILES) * PRICE_PER);
			}else if(miles > BASE_MILES_LONG){
				return (float) (BASE_PRICE + (BASE_MILES_LONG - BASE_MILES) * PRICE_PER + (miles - BASE_MILES_LONG) * PRICE_PER_EXTRA);
			}
		}else{
			if(miles <= BASE_MILES){
				return BASE_PRICE_NIGHT;
			}else if (miles > BASE_MILES && miles <= BASE_MILES_LONG){
				return (BASE_PRICE_NIGHT + (miles - BASE_MILES) * PRICE_PER_NIGHT);
			}else if(miles > BASE_MILES_LONG){
				return (float) (BASE_PRICE_NIGHT + (BASE_MILES_LONG - BASE_MILES) * PRICE_PER_NIGHT + (miles - BASE_MILES_LONG) * PRICE_PER_EXTRA_NIGHT);
			}
		}
		
		return -1;
	}
}
