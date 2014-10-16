<?
/****************************************************************************************
 * File Name	: result_query.php
 * Description	: choose product, firmware,image file,test suites, testers to query results  
 * Author	: Jing Ma
 * Copyright	: 
 * Project	: ATLAS
 * OS		: Linux
 * Date		: 2010-04-07
 ****************************************************************************************/
	include("./ATLAScom.php");
	navBar("ATLAS Results Query Page");
?>
<script src="./js/jquery-1.4.2.min.js"></script>	
<script type="text/javascript" src="./js/jquery.dynDateTime.js"></script>
<script type="text/javascript" src="./js/lang/calendar-en.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="./js/css/calendar-blue.css"  />
  
<script language = "JavaScript" >   

  var firmware_count=0;   
  var tsuite_count=0;
  var tbed_count=0;
  var users_count=0;
  firmware_arr = new Array();  
  tsuite_arr = new Array();   
  tbed_arr = new Array();   
  users_arr = new Array();  

  <?
		$dbh=dbConnect();
		mysql_select_db("ATLAS");   
	  $sql1 = "select FWVersion,ProductID,Image from firmware order by FWVersion";   
	  $result = mysql_query( $sql1 );   
	  $count = 0;
	  while($res1 = mysql_fetch_row($result)){   
  ?>   
 
	firmware_arr[<?=$count?>] = new Array("<?=$res1[0]?>","<?=$res1[1]?>","<?=$res1[2]?>");    
  <?   
	  $count++;   
	  }   
	  	echo "firmware_count=$count";   
	  	mysql_free_result($result);
	
  ?>   
  
  <?
	  $sql2 = "select distinct Tsuite,ProductID,FWVersion from testsuite";   
	  $result = mysql_query( $sql2 );   
	  $count = 0;
	  while($res2 = mysql_fetch_row($result)){   
  ?>   
 
	tsuite_arr[<?=$count?>] = new Array("<?=$res2[0]?>","<?=$res2[1]?>","<?=$res2[2]?>");    
  <?   
	  $count++;   
	  }   
	  	echo "tsuite_count=$count";   
	  	mysql_free_result($result);
	
  ?>   
  
  <?
	  $sql3 = "select TbedID,ProductID from testbed";   
	  $result = mysql_query( $sql3 );   
	  $count = 0;
	  while($res3 = mysql_fetch_row($result)){   
  ?>   
 
	tbed_arr[<?=$count?>] = new Array("<?=$res3[0]?>","<?=$res3[1]?>");    
  <?   
	  $count++;   
	  }   
	  	echo "tbed_count=$count";   
	  	mysql_free_result($result);
			
  ?>   
  
  <?
	  $sql4 = "select UserID,PassWord from users";   
	  $result = mysql_query( $sql4 );   
	  $count = 0;
	  while($res4 = mysql_fetch_row($result)){   
  ?>   
 
	users_arr[<?=$count?>] = new Array("<?=$res4[0]?>","<?=$res4[1]?>");    
  <?   
	  $count++;   
	  }   
	  	echo "users_count=$count";   
	  	mysql_free_result($result);
			mysql_close($dbh);
  ?>   

	function   changeproduct(ProductID)   
	{   
	
		document.query_form.fwversion_sl.length = 0;   
		document.query_form.testbed_sl.length = 0; 
		document.query_form.image_sl.length = 0; 
		document.query_form.testsuite_sl.length = 0; 
		var ProductID=ProductID;   
		var i;   
		for(i=0;i<firmware_count;i++)   
		{   		
			if(firmware_arr[i][1] == ProductID)   		
			{     	
				document.query_form.fwversion_sl.options[document.query_form.fwversion_sl.length] = new Option(firmware_arr[i][0],firmware_arr[i][0]);   
			}                   
		}   
		document.query_form.fwversion_sl.options[document.query_form.fwversion_sl.length-1].selected=true;
		for(i=0;i<tbed_count;i++)   
		{   		
			if(tbed_arr[i][1] == ProductID)   		
			{     	
				document.query_form.testbed_sl.options[document.query_form.testbed_sl.length] = new Option(tbed_arr[i][0],tbed_arr[i][0]);   
			}                   
		}   
	}           
	
	function   changefirmware(FWVersion)   
	{   
		document.query_form.image_sl.length = 0;   
		document.query_form.testsuite_sl.length = 0;   
		var FWVersion=FWVersion;   
		var ProductID=document.query_form.product_sl.options[document.query_form.product_sl.selectedIndex].value;
		var i;   
		for(i=0;i<firmware_count;i++)   
		{   		
			if((firmware_arr[i][0] == FWVersion) && (firmware_arr[i][1] == ProductID))	
			{     	
				document.query_form.image_sl.options[document.query_form.image_sl.length] = new Option(firmware_arr[i][2],firmware_arr[i][2]);   
			}                   
		}   
		
		for(i=0;i<tsuite_count;i++)   
		{   		
			if((tsuite_arr[i][2] == FWVersion) && (tsuite_arr[i][1] == ProductID))	
			{     	
				document.query_form.testsuite_sl.options[document.query_form.testsuite_sl.length] = new Option(tsuite_arr[i][0],tsuite_arr[i][0]);   
			}                   
		}   
	}
	function trim(s) {   
	  var count = s.length;   
	  var st    = 0;       // start   
	  var end   = count-1; // end   
	  
	  if (s == "") return s;   
	  while (st < count) {   
	    if (s.charAt(st) == " ")   
	      st ++;   
	    else  
	      break;   
	  }   
	  while (end > st) {   
	    if (s.charAt(end) == " ")   
	      end --;   
	    else  
	      break;   
	  }   
	  return s.substring(st,end + 1);   
	} 

	function checkForm(){  
		if (trim(document.query_form.product_sl.options[document.query_form.product_sl.selectedIndex].value)==""){  
			alert("please choose product"); 
			document.query_form.product_sl.focus(); 
			return false;  
		}
		
		if(trim(document.query_form.fwversion_sl.options[document.query_form.fwversion_sl.selectedIndex].value)==""){  
			alert("please choose firmware"); 
			document.query_form.fwversion_sl.focus(); 
			return false;  
		}
		
		if(trim(document.query_form.image_sl.options[document.query_form.image_sl.selectedIndex].value)==""){  
			alert("please choose image"); 
			document.query_form.image_sl.focus(); 
			return false;  
		}
		
		if(document.query_form.testsuite_sl.length==0){
				alert("please choose test suite"); 
				document.query_form.testsuite_sl.focus(); 
				return false;  
		}else {
			var i=0;
			var iflag=0;
			while(i<document.query_form.testsuite_sl.length){
				if(document.query_form.testsuite_sl.options[i].selected==true){
					iflag=1;
					break;
				} 
				i++; 
			}
			if(iflag==0)
			{
				alert("please choose test suite"); 
				document.query_form.testsuite_sl.focus(); 
				return false; 
			}
		}
		
		if(trim(document.query_form.testbed_sl.options[document.query_form.testbed_sl.selectedIndex].value)==""){  
			alert("please choose test bed"); 
			document.query_form.testbed_sl.focus();
			return false;  
		}
		
		if(trim(document.query_form.SDateTime.value)==""){  
			alert("please enter start time"); 
			document.query_form.SDateTime.focus();
			return false;  
		}
	
		if(trim(document.query_form.EDateTime.value)==""){  
			alert("please enter end time"); 
			document.query_form.EDateTime.focus();
			return false;  
		}  
		
		if(document.query_form.tester_sl.length==0){
				alert("please choose tester"); 
				document.query_form.tester_sl.focus(); 
				return false;  
		}else {
			var i=0;
			iflag=0;
			while(i<document.query_form.tester_sl.length){
				if(document.query_form.tester_sl.options[i].selected==true){
					iflag=1;
					break;
				} 
				i++; 
			}
			if(iflag==0)
			{
				alert("please choose tester"); 
				document.query_form.tester_sl.focus(); 
				return false; 
			}
		}
		
		return true;
	}  	
	
 </script>
 
<?php
	  
	displayform();

	function displayform()
	{	  	
		echo '<CENTER><H1><font color=blue>Results Query</font></H1></center>
		<center><form name="query_form" method="post" action="./results.php" onSubmit="return checkForm()">  
		<table border="0" cellspacing="0" cellpadding="0" width=45%>
		<tr>
		<table border="0" cellspacing="0" cellpadding="0" width=45%>
		  <tr height=40><td width=100>Product:</td>
		  	<td><select name="product_sl" onchange="javascript:changeproduct(document.query_form.product_sl.options[document.query_form.product_sl.selectedIndex].value)" style="width:120px">
		  	<option selected="selected" value="">-- product --</option>';
		  	
		$dbh=dbConnect();
		mysql_select_db("ATLAS"); 
		$query = "select ProductID, NameforTest from product";
		$pro_result = mysql_query($query);
		$pro_num=mysql_num_rows($pro_result);
		//echo $pro_num;
		for($i=0;$i<$pro_num;$i++){
			$pro_row = mysql_fetch_assoc($pro_result);
			$ProductID[$i]=$pro_row["ProductID"];
			$NameforTest[$i]=$pro_row["NameforTest"];
	
				echo '<option value="'.$ProductID[$i].'" >'.$NameforTest[$i].'</option>';
		}
						 	
		mysql_free_result($pro_result);

		
	echo '</select>
		  	</td>
		  </tr>
		  <tr height=40>
		    <td>Firmware:</td>
		    <td><select name="fwversion_sl"  onchange="javascript:changefirmware(document.query_form.fwversion_sl.options[document.query_form.fwversion_sl.selectedIndex].value)" onpropertychange="javascript:changefirmware(document.query_form.fwversion_sl.options[document.query_form.fwversion_sl.selectedIndex].value)" style="width:120px">
		      <option selected value="">-- firmware --</option>    
		    </select>
		    </td>
		  </tr>
		  
		  <tr height=40>
		    <td>Image:</td>
		    <td><select name="image_sl" style="width:250px">
		      <option>--image file--</option>
		    </select>
		    </td>
		  </tr>
		  	    
		  <tr>	  
		  	<td >Test Suite:</td>
		    <td><select name="testsuite_sl[]" id="testsuite_sl" size="6" multiple="multiple" style="width:150px">
		                
		     </select></td>		         
		  </tr>

		  <tr height=40>    
		    <td>Test Bed:</td>
		    <td><select name="testbed_sl" style="width:120px">
		      <option>--test bed--</option>
		    </select>
		    </td>
		  </tr>
		  </table>
		  </tr>
		  
		  <tr height=80>
		  <table border="0" cellspacing="0" cellpadding="0" width=45%>
		  <tr height=40>
		    <td width=100>Start from:</td>
		    <script type="text/javascript">
					jQuery(document).ready(function() {
						jQuery("#SDateTime").dynDateTime({
							showsTime: true,					
							electric: false,
							ifFormat: "%Y-%m-%d %H:%M:%S"				
						});
					});
				</script>
		    <td width=150><input name="SDateTime" type="text" id="SDateTime"  size="15" />
		    </td>
		    <td width=20 align=center>to:</td>
		    <script type="text/javascript">
					jQuery(document).ready(function() {
						jQuery("#EDateTime").dynDateTime({
							showsTime: true,
							ifFormat: "%Y-%m-%d %H:%M:%S"
						});
					});
				</script>
		    <td><input name="EDateTime" type="text" id="EDateTime"  size="15"/>
		    </td>
		  </tr>
		  
		  <tr>	  
		  	<td >Tester:</td>
		    <td><select name="tester_sl[]" id="tester_sl" size="5" multiple="multiple" style="width:150px">';
		                
                
		$query = "select UserID from users";
		$user_result = mysql_query($query);
		$user_num=mysql_num_rows($user_result);
		
		for($i=0;$i<$user_num;$i++){
			$pro_row = mysql_fetch_assoc($user_result);
			$UserID[$i]=$pro_row["UserID"];

			echo '<option value="'.$UserID[$i].'" >'.$UserID[$i].'</option>';
		}
						 	
		mysql_free_result($user_result);
		mysql_close($dbh);
		
		echo	 '</select></td>		         
		  </tr>
		  
		  <tr height=80>  
		  	<td></td>
		    <td><input type="submit" name="Submit"  style="width:70px" value=" Query " />
		    </td>
		    
		    <td>
		    <input type="reset" name="reset" style="width:70px" value=" Reset " />
		    </td>
		  </tr>
		  
		  
			</table>
			</tr>
		  </table>
		</form></center>';

		setfooter();
	}
?>


