<?
/****************************************************************************************
 * File Name	: job_submit.php
 * Description	: choose product, firmware,image file,test suites to launch tests  
 * Author	: Jing Ma
 * Copyright	: 
 * Project	: ATLAS
 * OS		: Linux
 * Date		: 2010-04-05
 *
 *   Modified by Aleon 06-14-2010
 ****************************************************************************************/
	include("./ATLAScom.php");
	if($_GET['action']=="submit")
		setRefreshHeader("ATLAS Job Submission Page","./status.php");
	else
		navBar("ATLAS Job Submission Page");
	session_start();
	$UserID = $_SESSION['currentUser'];
?>

<script language = "JavaScript">   

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
	  $sql4 = "select UserID from users";   
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

	function changeproduct(ProductID)   
	{   
	//	alert("haha");
	
		document.job_form.elements["fwversion_sl"].length = 0;   
		document.job_form.elements["testbed_sl"].length = 0; 
		document.job_form.elements["image_sl"].length = 0; 
		document.job_form.elements["testsuite_sl"].length = 0; 
		var ProductID=ProductID;   
		var i;   
		for(i=0;i<firmware_count;i++)   
		{   		
			if(firmware_arr[i][1] == ProductID)   		
			{     	
				document.job_form.elements["fwversion_sl"].options[document.job_form.elements["fwversion_sl"].length] = new Option(firmware_arr[i][0],firmware_arr[i][0]);   
			}                   
		}   
		document.job_form.elements["fwversion_sl"].options[document.job_form.elements["fwversion_sl"].length-1].selected=true;
		for(i=0;i<tbed_count;i++)   
		{   		
			if(tbed_arr[i][1] == ProductID)   		
			{     	
				document.job_form.elements["testbed_sl"].options[document.job_form.elements["testbed_sl"].length] = new Option(tbed_arr[i][0],tbed_arr[i][0]);   
			}                   
		}   
	}           
	
	function   changefirmware(FWVersion)   
	{   
		document.job_form.elements["image_sl"].length = 0;   
		document.job_form.elements["testsuite_sl"].length = 0;   
		var FWVersion=FWVersion;   
		var ProductID=document.job_form.elements["product_sl"].options[document.job_form.elements["product_sl"].selectedIndex].value;
		var i;   
		for(i=0;i<firmware_count;i++)   
		{   		
			if((firmware_arr[i][0] == FWVersion) && (firmware_arr[i][1] == ProductID))	
			{     	
				document.job_form.elements["image_sl"].options[document.job_form.elements["image_sl"].length] = new Option(firmware_arr[i][2],firmware_arr[i][2]);   
			}                   
		}   
		
		for(i=0;i<tsuite_count;i++)   
		{   		
			if((tsuite_arr[i][2] == FWVersion) && (tsuite_arr[i][1] == ProductID))	
			{     	
				document.job_form.elements["testsuite_sl"].options[document.job_form.elements["testsuite_sl"].length] = new Option(tsuite_arr[i][0],tsuite_arr[i][0]);   
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
		if (trim(document.job_form.product_sl.options[document.job_form.product_sl.selectedIndex].value)==""){  
			alert("please choose product"); 
			document.job_form.product_sl.focus(); 
			return false;  
		}
		
		if(trim(document.job_form.fwversion_sl.options[document.job_form.fwversion_sl.selectedIndex].value)==""){  
			alert("please choose firmware"); 
			document.job_form.fwversion_sl.focus(); 
			return false;  
		}
		
		if(trim(document.job_form.image_sl.options[document.job_form.image_sl.selectedIndex].value)==""){  
			alert("please choose image"); 
			document.job_form.image_sl.focus(); 
			return false;  
		}
		
		if(document.job_form.testsuite_sl.length==0){
				alert("please choose test suite"); 
				document.job_form.testsuite_sl.focus(); 
				return false;  
		}else {
			var i=0;
			var iflag=0;
			while(i<document.job_form.testsuite_sl.length){
				if(document.job_form.testsuite_sl.options[i].selected==true){
					iflag=1;
					break;
				} 
				i++; 
			}
			if(iflag==0)
			{
				alert("please choose test suite"); 
				document.job_form.testsuite_sl.focus(); 
				return false; 
			}
		}
		
		if(trim(document.job_form.testbed_sl.options[document.job_form.testbed_sl.selectedIndex].value)==""){  
			alert("please choose test bed"); 
			document.job_form.testbed_sl.focus();
			return false;  
		}
		if(trim(document.job_form.userid.value)==""){  
			alert("please enter user"); 
			document.job_form.userid.focus();
			return false;  
		}
	
		if(trim(document.job_form.passwd.value)==""){  
			alert("please enter password"); 
			document.job_form.passwd.focus();
			return false;  
		} 
 
		iflag=0;
		for(i=0;i<users_count;i++)   
		{   		
			if((users_arr[i][0] == trim(document.job_form.userid.value)) && (users_arr[i][1] == trim(document.job_form.passwd.value)))   		
			{     	
				iflag=1;   
			}                   
		}
		if(iflag==0)
		{
			alert("wrong userid or password"); 
			document.job_form.userid.focus(); 
			return false; 
		}
		return true;
	}  	
</script>

<?php
	  if($_GET['action']=="submit"){	
			submit_process();
		}else{
			displayform();
		}

	function displayform()
	{	  	
		echo '<CENTER><H1><font color=blue>Job Submission</font></H1></center>
					
		<center><form name="job_form" method="post" action="./job_submit.php?action=submit" onSubmit="return checkForm()">  
		<center><table border="0" cellspacing="0" cellpadding="0" width=40%>
		<tr>
		<Table border="0" cellspacing="0" cellpadding="0" width=40%>
		  <tr height=40><td width=100>Product:</td>
	<!--	  	<td><select name="product_sl" onpropertychange="javascript:changeproduct(document.job_form.product_sl.options[document.job_form.product_sl.selectedIndex].value)" style="width:120px"> -->
		  	<td><select name="product_sl"  onchange="javascript:changeproduct(document.job_form.product_sl.options[document.job_form.product_sl.selectedIndex].value)" style="width:120px">
		  	<option selected="selected" value="">-- product --</option>';
		  	
		$dbh=dbConnect();
		mysql_select_db("ATLAS"); 
		$query = "select ProductID, NameforTest from product";
		$pro_result = mysql_query($query);
		$pro_num=mysql_num_rows($pro_result);
	//	echo $pro_num;
		for($i=0;$i<$pro_num;$i++){
			$pro_row = mysql_fetch_assoc($pro_result);
			$ProductID[$i]=$pro_row["ProductID"];
			$NameforTest[$i]=$pro_row["NameforTest"];
	
				echo '<option value="'.$ProductID[$i].'" >'.$NameforTest[$i].'</option>';
		}
						 	
		mysql_free_result($pro_result);
		mysql_close($dbh);
		
		echo'</select>
		  	</td>
		  </tr>
		  
		  <tr height=40>
		    <td>Firmware:</td>
		    <td><select name="fwversion_sl" onclick="changefirmware(document.job_form.fwversion_sl.options[document.job_form.fwversion_sl.selectedIndex].value)" onpropertychange="changefirmware(document.job_form.fwversion_sl.options[document.job_form.fwversion_sl.selectedIndex].value)" style="width:120px">
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
			  <table border="0" cellspacing="0" cellpadding="0" width=40%>
				  <tr height=80>  
				  	<td></td>
				    <td><input type="submit" name="Submit"  style="width:70px" value=" Submit " />
				    </td>
				    
				    <td>
				    <input type="reset" name="reset" style="width:70px" value=" Reset " />
				    </td>
				  </tr>
				</table>
			</tr>
		
		 </table></center>
		</form></center>';

		setfooter();
	}
	
	function submit_process()
	{
		$ProductID=$_POST['product_sl'];
		$FWVersion=$_POST['fwversion_sl'];
		$Image=$_POST['image_sl'];
		$TbedID=$_POST['testbed_sl'];
		
		$UserID = $_SESSION['currentUser'];
		#$UserID=$_POST['userid'];
	
		$i=0;
		while($i <= count($_POST['testsuite_sl']) - 1){
		 $Tsuite[$i]=$_POST['testsuite_sl'][$i];		
		 $i++;	 
		}
	

		$dbh=dbConnect();
		mysql_select_db("ATLAS"); 
		$lock ="lock tables job write";
		$result = mysql_query($lock);
		
		if(!$result){
			echo "<p><font color=red size=4>Please reSubmit</font></p>";
			mysql_free_result($result);
			mysql_close($dbh);
			setfooter();
			exit;
		}		
		
		$query="select now() as SubTime, DATE_FORMAT(now(),'%Y%m%d%H%i%s') as JobIDTime";
			
		$result=mysql_query($query);
		while($res = mysql_fetch_row($result))
		{   
  		$SubTime=$res[0];
 			$JobIDTime=$res[1];
		}  
		
//		echo 'subtime:'.$SubTime;
//		echo 'JobIDTime:'.$JobIDTime;
		mysql_free_result($result);
			
		for($i=0;$i<=count($Tsuite)-1;$i++){	
			if (strlen($i)==1){
				$JobID=$JobIDTime.'00'.$i;
			}else if(strlen($i)==2){
				$JobID=$JobIDTime.'0'.$i;
			}else{
				$JobID=$JobIDTime.$i;
			}
			
			$insert = "insert into job values('$JobID','$TbedID','$ProductID','$FWVersion','$Image','$Tsuite[$i]',0,'$SubTime','','','$UserID');";
			
			$result = mysql_query($insert);
			if(!$result){
				echo "<p><font color=red size=4>Please reSubmit</font></p>";
				$unlock ="unlock tables";
				$result = mysql_query($unlock);
				mysql_free_result($result);
				mysql_close($dbh);
				setfooter();
				exit;
			}else{
				mysql_free_result($result);
				//sleep(1);
			}
		}
		
		$unlock ="unlock tables";
		$result = mysql_query($unlock);
		mysql_free_result($result);
		mysql_close($dbh);
		
	//	echo '<META http-equiv=REFRESH content=3;URL=./index.php>';
	echo '<center><table border="0" cellspacing="0" cellpadding="0" width=40% height=400>
		<tr><td><font color=red size=10><center>Submit Successfully!</center></font></td></tr></table></center>';
		
		setfooter();
		//sleep(5);
	}
?>


