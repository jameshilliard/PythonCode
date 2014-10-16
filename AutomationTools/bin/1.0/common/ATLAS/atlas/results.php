<?php
/****************************************************************************************
 * File Name	: results.php
 * Description	: statistics of test results  
 * Author	: Jing Ma
 * Copyright	: 
 * Project	: ATLAS
 * OS		: Linux
 * Date		: 2010-04-10
 * Change history :
 *  # Change display mode on results main page
 *                          Hugo 08/2010
 *
 *
 ****************************************************************************************/
	include("./ATLAScom.php");

	navBar("ATLAS Test Results Page");
	echo '<CENTER><H1><font color=blue>Test Results</font></H1></center>';
	
	$JobIDInfo=$_GET['JobID'];
	//echo 'JobID:'.$JobIDInfo;
	if($JobIDInfo=='')
		multiresult();
	else
		singleresult($JobIDInfo);
		
	function multiresult(){
		
		$ProductID=$_POST['product_sl'];
		$FWVersion=$_POST['fwversion_sl'];
		$Image=$_POST['image_sl'];
		$TbedID=$_POST['testbed_sl'];
		$StartSubTime=$_POST['SDateTime'];
		$EndSubTime=$_POST['EDateTime'];
		
		$i=0;
		$sWhere1='Tsuite in (';
		while($i <= count($_POST['testsuite_sl']) - 1){
			$sTsuite[$i]=$_POST['testsuite_sl'][$i];
			$sWhere1=$sWhere1."'$sTsuite[$i]'".',';		
			$i++;	 
		}
		$sWhere1=trim($sWhere1,",").') ';
		
		$i=0;
		$sWhere2='and UserID in (';
		while($i <= count($_POST['tester_sl']) - 1){
			$sUserID[$i]=$_POST['tester_sl'][$i];	
			$sWhere2=$sWhere2."'$sUserID[$i]'".',';		
			$i++;	 
		}
		$sWhere2=trim($sWhere2,",").') ';
		
		if($ProductID=="" || $FWVersion=="" || $Image=="" || $TbedID=="" || count($sTsuite)==0 || count($sUserID)==0)
		{
			echo "<p><center><font color=red size=4>No such result!</font></center></p>";
		}
		
		$dbh=dbConnect();
		mysql_select_db("ATLAS"); 
			
		$job_query="select JobID,Tsuite,SubTime,StartTime,SEC_TO_TIME(TIME_TO_SEC(EndTime)-TIME_TO_SEC(StartTime)) as Inter,UserID from 
								job where ProductID='$ProductID' and FWVersion='$FWVersion' and Image='$Image' and 
								TbedID='$TbedID' and SubTime >= '$StartSubTime' and SubTime <= '$EndSubTime' and ".$sWhere1.$sWhere2;
		//echo $job_query;
		$job_result = mysql_query($job_query);
		$job_num=mysql_num_rows($job_result);
		//	echo $pro_num;
		for($i=0;$i<$job_num;$i++){
			$job_row = mysql_fetch_assoc($job_result);
			$JobID[$i]=$job_row["JobID"];
			$Tsuite[$i]=$job_row["Tsuite"];
			$SubTime[$i]=$job_row["SubTime"];
			$StartTime[$i]=$job_row["StartTime"];
			$Inter[$i]=$job_row["Inter"];
			$UserID[$i]=$job_row["UserID"];
			
			$SuiteID=$ProductID.'-'.$FWVersion.'-'.$Tsuite[$i];
			$tcase_query="select count(*) as TotalNum from suitecase where SuiteID='$SuiteID'";
		//	echo $tcase_query;
			$tcase_result = mysql_query($tcase_query);
			$TotalNum=mysql_result($tcase_result,0,"TotalNum");
			mysql_free_result($tcase_result);
			
			$tcase_query='select count(*) as ExecNum from testresult where JobID="'.$JobID[$i].'" and Comments!="nc"';
		//	echo $tcase_query;
			$tcase_result = mysql_query($tcase_query);
			$ExecNum=mysql_result($tcase_result,0,"ExecNum");
			mysql_free_result($tcase_result);
			
			$tcase_query="select count(*) as Passed from testresult where JobID='$JobID[$i]' and Comments!='nc' and Result=0";
			$tcase_result = mysql_query($tcase_query);
			$Passed=mysql_result($tcase_result,0,"Passed");
			mysql_free_result($tcase_result);
			
			$tcase_query="select count(*) as Failed from testresult where JobID='$JobID[$i]' and Comments!='nc' and Result=1";
			$tcase_result = mysql_query($tcase_query);
			$Failed=mysql_result($tcase_result,0,"Failed");
			mysql_free_result($tcase_result);
			
			echo '<center><table border="0" cellspacing="0" cellpadding="0" width=800>
	    	<tr>	
	      	<table border="0" cellspacing="0" cellpadding="0" width=800>
	          <tr height=30>
		           <td width="200"><strong>Job ID: &nbsp;<font color="#FF00FF">'.$JobID[$i].'</font></strong></td>
							 <td align=right width="600">Start from '.$StartTime[$i].'</td>
	          </tr>
	    		</table>
	    		
	    		<table border="0" cellspacing="0" cellpadding="0" width=800>
					  <tr height=30>
			      	<td align=left width="300"><strong>Product/ Firmware/ TestSuite</strong></td>
							<td align=center width="100"><strong>Duration</strong></td>
							<td align=center width="100"><strong>Test Bed</strong></td>
							<td align=center width="100"><strong>Total</strong></td>
							<td align=center width="100"><strong>Exec./Nonexec.</strong></td>
							<td align=center width="100"><strong>Pass / Fail</strong></td>
			      </tr>
			      
					  <tr height=30>
			        <td align=left width="300">'.$ProductID.' / '.$FWVersion.' / '.$Tsuite[$i].'</td>
							<td align=center width="100">'.$Inter[$i].'</td>
							<td align=center width="100">'.$TbedID.'</td>
							<td align=center width="100">'.$TotalNum.'</td>
							<td align=center width="100">'.$ExecNum.' / '.($TotalNum-$ExecNum).'</td>
							<td align=center width="100"><font color="#00FF00">'.$Passed.'</font> / <font color="#FF0000">'.$Failed.'</font></td>
			      </tr>
	     		</table>
	  		</tr>
	  		<tr>
	  			<TABLE width="800" border=0 cellpadding="1" cellspacing="2" style="margin:auto;">
						<tr style="background:#EFEFEF;">
							<td width="50" nowrap align=center bgcolor="#666FF"><strong>Time</strong></td>
							<td width="200" nowrap align=center bgcolor="#666FF"><strong>Test Case</strong></td>
							<td width="400" nowrap align=center bgcolor="#666FF"><strong>Description</strong></td>
							<td width="50" nowrap align=center bgcolor="#666FF"><strong>Status</strong></td>
							<td width="100"nowrap align=center bgcolor="#666FF"><strong>Comments</strong></td>
						</tr>';
			$tcase_query="select sec_to_time(Duration) as tDuration,TcaseID,Result,Comments,Log 
										from testresult where JobID='$JobID[$i]' order by StartTime";
			$tcase_result = mysql_query($tcase_query);
			$tcase_num=mysql_num_rows($tcase_result);
		
			for($j=0;$j<$tcase_num;$j++){
				$tcase_row = mysql_fetch_assoc($tcase_result);
				$tDuration[$j]=$tcase_row["tDuration"];
				$TcaseID[$j]=$tcase_row["TcaseID"];
				$Comments[$j]=$tcase_row["Comments"];
				$Log[$j]=$tcase_row["Log"];
				
				if ($tcase_row["Comments"]=='nc')
					$Comments[$j]='non-case <a href='.$Log[$j].' target="_blank">log</a>';
				else if ($tcase_row["Comments"]=='')
					$Comments[$j]='<a href='.$Log[$j].' target="_blank">log</a>';
				else
					$Comments[$j]='no log';
					
				if ($tcase_row["Result"]==0)
					$Result[$j]='<font color="#00FF00">pass</font>';
				else if ($tcase_row["Result"]==1)
					$Result[$j]='<font color="#FF0000">fail</font>';
				else
					$Result[$j]='noexec';
			
				$desc_query="select Description from testcase where TcaseID = '$TcaseID[$j]'";
		//		echo $desc_query;
				$desc_result = mysql_query($desc_query);
				$Description=mysql_result($desc_result,0);
				mysql_free_result($desc_result);
				
				echo '<tr height=25>
					    <td nowrap align=left bgcolor=#D7EBFF>'.$tDuration[$j].'</td>
							<td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$TcaseID[$j].'</div></td>
					    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$Description.'</div></td>
					    <td bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="center">'.$Result[$j].'</div></td>
					    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$Comments[$j].'</div></td>
					  </tr>';
			}
			echo'</table>
				<p>
		    	<label>&nbsp;</label>
			  </p>
			  <p>
			    <label>&nbsp;</label>
			  </p>';
	  
			mysql_free_result($tcase_result);
			echo '
				</tr></table></center>';
		
		}
	}
	
	function singleresult($JobIDInfo){
		
		$dbh=dbConnect();
		mysql_select_db("ATLAS"); 
			
		$job_query="select JobID,ProductID,FWVersion,Tsuite,SubTime,StartTime,SEC_TO_TIME(TIME_TO_SEC(EndTime)-TIME_TO_SEC(StartTime)) as Inter,UserID from 
								job where JobID='$JobIDInfo'";
		//echo $job_query;
		$job_result = mysql_query($job_query);
		$job_num=mysql_num_rows($job_result);
		//	echo $pro_num;
		
		$job_row = mysql_fetch_assoc($job_result);
		$JobID=$job_row["JobID"];
		$ProductID=$job_row["ProductID"];
		$FWVersion=$job_row["FWVersion"];
		$Tsuite=$job_row["Tsuite"];
		$SubTime=$job_row["SubTime"];
		$StartTime=$job_row["StartTime"];
		$Inter=$job_row["Inter"];
		$UserID=$job_row["UserID"];
			
		$SuiteID=$ProductID.'-'.$FWVersion.'-'.$Tsuite;
		$tcase_query="select count(*) as TotalNum from suitecase where SuiteID='$SuiteID'";
		//	echo $tcase_query;
		$tcase_result = mysql_query($tcase_query);
		$TotalNum=mysql_result($tcase_result,0,"TotalNum");
		mysql_free_result($tcase_result);
			
		$tcase_query='select count(*) as ExecNum from testresult where JobID="'.$JobID.'" and Comments!="nc"';
		//	echo $tcase_query;
		$tcase_result = mysql_query($tcase_query);
		$ExecNum=mysql_result($tcase_result,0,"ExecNum");
		mysql_free_result($tcase_result);
			
		$tcase_query="select count(*) as Passed from testresult where JobID='$JobID' and Comments!='nc' and Result=0";
		$tcase_result = mysql_query($tcase_query);
		$Passed=mysql_result($tcase_result,0,"Passed");
		mysql_free_result($tcase_result);
			
		$tcase_query="select count(*) as Failed from testresult where JobID='$JobID' and Comments!='nc' and Result=1";
		$tcase_result = mysql_query($tcase_query);
		$Failed=mysql_result($tcase_result,0,"Failed");
		mysql_free_result($tcase_result);
			
		echo '<center><table border="0" cellspacing="0" cellpadding="0" width=800>
	    	<tr>	
	      	<table border="0" cellspacing="0" cellpadding="0" width=800>
	          <tr height=30>
		           <td width="200"><strong>Job ID: &nbsp;<font color="#FF00FF">'.$JobID.'</font></strong></td>
							 <td align=right width="600">Start from '.$StartTime.'</td>
	          </tr>
	    		</table>
	    		
	    		<table border="0" cellspacing="0" cellpadding="0" width=800>
					  <tr height=30>
			      	<td align=left width="300"><strong>Product/ Firmware/ TestSuite</strong></td>
							<td align=center width="100"><strong>Duration</strong></td>
							<td align=center width="100"><strong>Test Bed</strong></td>
							<td align=center width="100"><strong>Total</strong></td>
							<td align=center width="100"><strong>Exec./Nonexec.</strong></td>
							<td align=center width="100"><strong>Pass / Fail</strong></td>
			      </tr>
			      
					  <tr height=30>
			        <td align=left width="300">'.$ProductID.' / '.$FWVersion.' / '.$Tsuite.'</td>
							<td align=center width="100">'.$Inter.'</td>
							<td align=center width="100">'.$TbedID.'</td>
							<td align=center width="100">'.$TotalNum.'</td>
							<td align=center width="100">'.$ExecNum.' / '.($TotalNum-$ExecNum).'</td>
							<td align=center width="100"><font color="#00FF00">'.$Passed.'</font> / <font color="#FF0000">'.$Failed.'</font></td>
			      </tr>
	     		</table>
	  		</tr>
	  		<tr>
	  			<TABLE width="800" border=0 cellpadding="1" cellspacing="2" style="margin:auto;">
						<tr style="background:#EFEFEF;">
							<td width="50" nowrap align=center bgcolor="#666FF"><strong>Time</strong></td>
							<td width="200" nowrap align=center bgcolor="#666FF"><strong>Test Case</strong></td>
							<td width="400" nowrap align=center bgcolor="#666FF"><strong>Description</strong></td>
							<td width="50" nowrap align=center bgcolor="#666FF"><strong>Status</strong></td>
							<td width="100"nowrap align=center bgcolor="#666FF"><strong>Comments</strong></td>
						</tr>';
						
			$tcase_query="select sec_to_time(Duration) as tDuration,TcaseID,Result,Comments,Log 
										from testresult where JobID='$JobID' order by StartTime";
			$tcase_result = mysql_query($tcase_query);
			$tcase_num=mysql_num_rows($tcase_result);
		
			for($j=0;$j<$tcase_num;$j++){
				$tcase_row = mysql_fetch_assoc($tcase_result);
				$tDuration[$j]=$tcase_row["tDuration"];
				$TcaseID[$j]=$tcase_row["TcaseID"];
				$Comments[$j]=$tcase_row["Comments"];
				$Log[$j]=$tcase_row["Log"];
				
				if ($tcase_row["Comments"]=='nc')
					$Comments[$j]='non-case <a href='.$Log[$j].' target="_blank">log</a>';
				else if ($tcase_row["Comments"]=='')
					$Comments[$j]='<a href='.$Log[$j].' target="_blank">log</a>';
				else
					$Comments[$j]='no log';
					
				if ($tcase_row["Result"]==0)
					$Result[$j]='<font color="#00FF00">pass</font>';
				else if ($tcase_row["Result"]==1)
					$Result[$j]='<font color="#FF0000">fail</font>';
				else
					$Result[$j]='noexec';
			
				$desc_query="select Description from testcase where TcaseID = '$TcaseID[$j]'";
		//		echo $desc_query;
				$desc_result = mysql_query($desc_query);
				$Description=mysql_result($desc_result,0);
				mysql_free_result($desc_result);
				
				echo '<tr height=25>
					    <td nowrap align=left bgcolor=#D7EBFF>'.$tDuration[$j].'</td>
							<td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$TcaseID[$j].'</div></td>
					    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$Description.'</div></td>
					    <td bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="center">'.$Result[$j].'</div></td>
					    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF><div align="left">'.$Comments[$j].'</div></td>
					  </tr>';
			}
			echo'</table>
				<p>
		    	<label>&nbsp;</label>
			  </p>
			  <p>
			    <label>&nbsp;</label>
			  </p>';
	  
			mysql_free_result($tcase_result);
			echo '
				</tr></table></center>';	
		
	}
		setfooter();
		
?>
