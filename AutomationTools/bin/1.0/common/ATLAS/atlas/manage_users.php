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
 * File Name	: manage_users.php,v $
 * Description	: The file is used to display users infomation and manage.
 *
 * Copyright	: @1999-2010 Actiontec Electronics, Inc. 
 * Project	: ATLAS
 * Author	: Aleon
 * @version $Revision: 1.0
 * Date		: 2010-04-07
 ****************************************************************************************/
include("./ATLAScom.php");
navBar("manage_users");

/**
 * Execute to delete user;
 */
if($_GET['action']=="delete"){
	//ho 'awdad';
	$userID = $_GET['user_id'];
	$dbh = dbConnect();
	mysql_select_db("ATLAS",$dbh); 
	$delete_user = "delete from users where UserID='".$userID."'";
	$result = mysql_query($delete_user);
	if($result) {
		echo '<script language="javascript">
		window.location="manage_users.php";	
	   	 </script>';	
	} else {
		setHeader("Deleting");
		echo 'The operation is abnormally,';
		setFooter();
	}
	
} 

else display();


setFooter();
/**
 * The function is for manage user table;
 */
function display()
{	
	session_start();
	$userID = $_SESSION['currentUser'];
	
    	$dbh = dbConnect();
	mysql_select_db("ATLAS",$dbh); 
    	/**
	 * Display all user from database table;
	 */
	$query="select * from users where UserID='$userID' and GroupID='Admin'";
   	$result = mysql_query($query);

        $num_results = mysql_num_rows($result);
        /**
         * Verify if there is reduplicate user in databases;
         */
	//echo $num_results;
        if($num_results != 1){
 		//echo $num_results;
                 echo '<center><table border="0" cellspacing="0" cellpadding="0" width=60% height=300>
                                <tr><td align="center"><font color=green size=12><a href=job_submit.php>Sorry '.$userID.',you have NO permissions to manage!                                    </a></font></td></tr></table></center>';
                mysql_close($dbh);
                setFooter();
                exit;
        } else {

		echo '<center><H1><font color=blue>Users</font></H1></center>';
    		$query_all="select * from users";
		$result_all = mysql_query($query_all); 
    		$obj=mysql_fetch_field($result_all);
    		echo '<table border="1" cellspacing="2" cellpadding="1" align=center width=800>';
    		//echo "<option><h1>".$obj->table."</h1></option>";
    		
     
    	  	/**
		 * Display the row title of users table;
		 */
		echo '<tr bgcolor="#68838B">';
    		for($i=0; $i < mysql_num_fields($result_all); $i++)
    		{
						echo '<th>'.mysql_field_name($result_all,$i).'</th>';
    		}
    				echo '<th>Operate</th>';
    				echo '<th>  </th>';
    		echo '</tr>';
	
		/**
		 * Display the detail info of user table 
	  	 */
    		while($dataArr=mysql_fetch_row($result_all))
    		{
 			echo "<tr bgcolor='#CFCFCF'>";
			foreach($dataArr as $value)
			{
	    			echo "<td>$value</td>";
			}
			$select_user=$dataArr[0];
			/**
			 * select user and execute operating of edit or delete;
		 	 */
			echo '<td align="center"><a href="register/modify_account.php?action=modify&user_id='.$select_user.'"> Edit </td>';
			echo '<td align="center"><a href="manage_users.php?action=delete&user_id='.$select_user.'"><img src="./image/trash.png"></a></td>';
			echo "</tr>";
    		}

		echo '<table align ="center" width=60%>
		
			<tr height=10>
				<td> </td>
			</tr>
			<tr>
			<form method=post action="register/create_user.php">
				<td align=left><input type=submit value=" Create " name="Create"></td></form>
			</tr>
		     </table>';
	mysql_free_result($result);
	mysql_close($dbh);
	}
}

?>
