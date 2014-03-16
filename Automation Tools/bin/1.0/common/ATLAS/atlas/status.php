<?php
/****************************************************************************************
 *  Copyright 1999-1010 - Actiontec Electronics, Inc. - All rights reserved;
 * **************************************************************************************
 *
 *  This source code is the sole property of Actiontec Electronics with all rights
 *  reserved. It is expressly prohibited to distribute in any manner any parts of
 *  the original source code, whether in source or object form, without the express 
 *  written permission from Actiontec Electronics.
 *
 *  Actiontec Electronics (Shanghai),Inc.
 *  9F (No.8 building) No.120, Lane 91, e'Shan RD, Shanghai
 *  Tel: 86-021-58206778
 * **************************************************************************************
 * File Name    : status.php,v $
 * Description  : The file is for display the current status of test bed.
 *			including TbedID, User Product and Testsuite etc.
 *
 * Copyright    : @1999-2010 Actiontec Electronics, Inc. 
 * Project      : ATLAS
 * Author	: Aleon
 * @version $Revision: 1.0
 * Date         : 2010-04-07
 ****************************************************************************************/
include("ATLAScom.php");

navBar("ATLAS Testbed Status Page");
/**
 * Delete record from testing status of testbed;
 */
if($_GET['action']=="delete"){
	
        $jobID = $_GET['job_id'];
        $dbh = dbConnect();
        mysql_select_db("ATLAS",$dbh);
        $delete_job = "delete from job where jobID='$jobID'";
        $result = mysql_query($delete_job);
        if($result) {
                echo '<script language="javascript">
                window.location="status.php";     
                 </script>';
        } else {
                setHeader("Deleting");
                echo 'The operation is abnormally,';
                setFooter();
        }

}
/**
 * Display testing status of testbed;
 */
$_GET['action']=="status";

	echo '<center><H1><font color=blue>Running Status</font></H1></center>';
        /**
         * Refresh the status of job table interval per 3 seconds;
         */
        header("refresh: 5; url=status.php");

 	/**
 	 * Connect database;
 	 */
	$dbh=dbConnect();
	mysql_select_db("ATLAS",$dbh);
	
	/**
 	 * Get Tbed ID from testbed database;
  	 */
	$query1="select distinct TbedID from testbed order by TbedID";
	$result1 = mysql_query($query1);
	$num_results = mysql_num_rows($result1); 		
  		
	/**
    	 * Get testbed status info from Job database;
         */
	$query2="select JobID,TbedID,ProductID,FWVersion,Tsuite,Status,UserID from job";
	echo '<center><table border="0" cellpadding="1" cellspacing="2" style="margin:auto;" width=60%>';

        	
       	 	echo '<tr style="background:#EFEFEF;">
        	
                <td nowrap align=center bgcolor="#666FF">Test Bed</td>
                <td nowrap align=center bgcolor="#666FF">Product</td>
                <td nowrap align=center bgcolor="#666FF">Firmware</td>
                <td nowrap align=center bgcolor="#666FF">Test Suite</td>
                <td nowrap align=center bgcolor="#666FF">Status</td>
                <td nowrap align=center bgcolor="#666FF">Tester</td>
                <td nowrap align=center bgcolor="#666FF">Operate</td>
      		 </tr>';       	

		for ($i=0; $i<$num_results; $i++)
		{
			$row = mysql_fetch_assoc($result1);
			$tbedID[$i]=$row["TbedID"];
			
			//echo $tbedID[$i].' ';
			$query3="select JobID,TbedID,ProductID,FWVersion,Tsuite,Status,UserID from job where TbedID='$tbedID[$i]' and Status != 2 and Status !=3";
			//echo $query3;
			$result3 = mysql_query($query3);				
			$num_3 = mysql_num_rows($result3);
	
			if($num_3>0)
			{
				/**
        	 		 * Display the current status of testbed;
        	    		 */
				while($dataArr=mysql_fetch_row($result3))
       		 		{
					echo "<tr align='center' height=30>";
                        		echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$dataArr[1].'</td>';
                       			echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$dataArr[2].'</td>';
                        		echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$dataArr[3].'</td>';
                        		echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$dataArr[4].'</td>';
                        		switch($dataArr[5])
                        		{
                        		case 0:
                                		echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF><font color='blue'>Pending</font></td>";
                               			break;
                        		case 1: 
                                		echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF><font color='red'>Running</font></td>";
                                		break;
                        		case 2:	
                                		echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF><font color='yellow'>Done</font></td>";
                                		break;
                        		case 3:
                                		echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF><font color='red'>Wrong</font></td>";
                                		break;
                        		default:
                                		echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF><font color='purple'>N/A</font></td>";
                       			}	
                       			echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>'.$dataArr[6].'</td>';
                       			if($dataArr[5] == 0){
						echo '<td align="center" bordercolor="#D7EBFF" bgcolor=#D7EBFF><a href="status.php?action=delete&job_id='.$dataArr[0].'"><img src="./image/trash.png"></a></td>';
					}elseif($dataArr[5] == 1){
						echo '<th bordercolor="#D7EBFF" bgcolor=#D7EBFF>Active</th>';
					}else{
                       				echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>Inactive</td>';
					}
		                    }
		
				}else{
				/**
        	 	         * Display the free testbed;
        	    		 */
				       echo "<tr align='center' bgcolor='#CFCFCF' height=30>";
					   echo "<td bordercolor=#D7EBFF bgcolor=#D7EBFF >$tbedID[$i]</td>";
					   echo '<td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>
					   <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>
					   <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>
					   <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>
					   <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>
					   <td bordercolor="#D7EBFF" bgcolor=#D7EBFF>N/A</td>';
					echo "</tr>";
	
			  }
			    
		}   
				
      
		echo "</table></center>";
    mysql_free_result($result1);
    mysql_free_result($result3);
    mysql_close($dbh);

setFooter();
?>
