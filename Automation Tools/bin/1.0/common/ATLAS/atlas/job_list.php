<?php
/****************************************************************************************
 * File Name	: job_list.php
 * Description	: This page is used to display all jobs info  
 * Author	: Jing Ma
 * Copyright	: 
 * Project	: ATLAS
 * OS		: Linux
 * Date		: 2010-05-24
 ****************************************************************************************/
	include("./ATLAScom.php");

	navBar("ATLAS Job List Page");
	echo '<CENTER><H1><font color=blue>Job List</font></H1></center>';
	
	$index=intval($_GET['index']);  
 	$limit=15;    //job display number in one page
 	$start=($index-1)*$limit+1;
				
	$dbh=dbConnect();
	mysql_select_db("ATLAS"); 
		
	$job_query="select SubTime,JobID,ProductID,FWVersion,Tsuite,Status,UserID from 
							job order by SubTime desc limit $start, $limit ";
	
	$job_result = mysql_query($job_query);
	$job_num=mysql_num_rows($job_result);
					
	if($index<1)
 		$info="Wrong index #";
 	else if($job_num < $limit)
 		$info='No.'.$start.'-'.($start+$job_num-1);
 	else
 		$info='No.'.$start.'-'.($start+$limit-1);
 	
	$previnfo='<a href="./job_list.php?index='.($index-1).'"> <strong>&lt; prev</strong></a>';
 	$nextinfo='<a href="./job_list.php?index='.($index+1).'"> <strong>next &gt;</strong></a>';
 	
// echo $nextinfo;
	if(($index-1) < 1)
		$previnfo='';
	if($job_num < $limit)
		$nextinfo='';	
//	echo $nextinfo;
	
	echo '<center>
  			<TABLE width="800" border=0 cellpadding="1" cellspacing="2" style="margin:auto;">
  			<table width="800">
	  			<tr height=25>	  
					  <td align=left>'.$info.'</td>
					  <td ></td>
					  <td ></td>
					  <td align=right><a href="./result_query.php" class="STYLE1">Advanced Query</a></td>
				  </tr>
				</table>
				<TABLE width="800" border=0 cellpadding="1" cellspacing="2" style="margin:auto;">
					<tr style="background:#EFEFEF;">
						<td width="150" nowrap align=center bgcolor="#666FF"><strong>Time</strong></td>
						<td width="150" nowrap align=center bgcolor="#666FF"><strong>JobID</strong></td>
						<td width="75" nowrap align=center bgcolor="#666FF"><strong>Product</strong></td>
						<td width="75" nowrap align=center bgcolor="#666FF"><strong>Firmware</strong></td>
						<td width="150"nowrap align=center bgcolor="#666FF"><strong>Test Suite</strong></td>
						<td width="75" nowrap align=center bgcolor="#666FF"><strong>Status</strong></td>
						<td width="75" nowrap align=center bgcolor="#666FF"><strong>Tester</strong></td>
					</tr>';
		
	//echo $pro_num;
	for($i=0;$i<$job_num;$i++){
		$job_row = mysql_fetch_assoc($job_result);
		$SubTime[$i]=$job_row["SubTime"];
		$JobID[$i]=$job_row["JobID"];
		$ProductID[$i]=$job_row["ProductID"];
		$FWVersion[$i]=$job_row["FWVersion"];
		$Tsuite[$i]=$job_row["Tsuite"];
		$UserID[$i]=$job_row["UserID"];

		$result_query = "select TcaseID from testresult where JobID='$JobID[$i]' and Result=1";	
		$ret_result = mysql_query($result_query);
		$result_num = mysql_num_rows($ret_result);
		switch($job_row["Status"]){
			case "0":
				$Status[$i]='<font color="#FF00FF">Pending</font>';
				break;
			case "1":
				$Status[$i]='<font color="#0000FF">Running</font>';
				break;
			case "2":
				if($result_num == 0) 
					$Status[$i]='<font color="#00FF00">Done</font>';
				else
					$Status[$i]='<font color="#FF0000">Done</font>';
				break;
			case "3":
				$Status[$i]='<font color="#FF0000">Fail</font>';
				break;
			case "4":
				$Status[$i]="Wrong";
				break;
			default:
				$Status[$i]="error status";
				break;
	}
		
		echo '<tr height=25 align=center>
				    <td nowrap  bgcolor=#D7EBFF>'.$SubTime[$i].'</td>
						<td  bordercolor="#D7EBFF" bgcolor=#D7EBFF> <a href="./results.php?JobID='.$JobID[$i].'" class="STYLE1">'.$JobID[$i].'</a></td>
				    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$ProductID[$i].'</td>
				    <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$FWVersion[$i].'</td>
				    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$Tsuite[$i].'</td>
				    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$Status[$i].'</td>
				    <td  bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$UserID[$i].'</td>
				  </tr>';	
			
		}
		
		
		echo '<tr height=25><td></td></tr>
				<tr height=25>
					<td ></td>
					<td ></td>
					<td ></td>
					<td ></td>
					<td ></td>
					<td align=center>'.$previnfo.'</td>
					<td align=center>'.$nextinfo.'</td>
				</tr>
		
			</table></center>
			<p>
	    	<label>&nbsp;</label>
		  </p>
		  <p>
		    <label>&nbsp;</label>
		  </p>';
  
		mysql_free_result($job_result);
		
		setfooter();
		
?>
