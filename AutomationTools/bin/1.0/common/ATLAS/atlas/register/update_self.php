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
 * File Name	: update_self.php,v $
 * Description	: The file is used to update user-self infomation;
 *
 * Copyright	: @1999-2010 Actiontec Electronics, Inc. 
 * Project	: ATLAS
 * Author	: Aleon
 * @version $Revision: 1.0
 * Date		: 2010-04-12
 ****************************************************************************************/
include("../ATLAScom.php");
registerNavBar("Update your Information");
/**
 * Modify the user infomation;
 */
if($_GET['action']=="update"){
	$_user_id=$_GET['user_id'];
	$_passwd=$_POST['newpasswd'];
	$_email=$_POST['email'];
	$_group=$_POST['group'];
	$_description=$_POST['description'];
	
        if(strlen(trim($_passwd))==0){
                displayerror("'Password' should not be null!",$_user_id,$_passwd,$_email,$_group,$_description);
                setFooter();
                exit;
        }
        if(strlen(trim($_email))==0){
                displayerror("'EMAIL' should not be null!",$_user_id,$_passwd,$_email,$_group,$_description);
                setFooter();
                exit;
        }

    account($_user_id,$_passwd,$_group,$_email,$_description);
}
/**
 * The function is for modify user info from databases;
 */
function account($_user_id,$_passwd,$_group,$_email,$_description)
{
	$dbh = dbConnect();
	$select_db = mysql_select_db("ATLAS",$dbh); 
	if (!$select_db) {
		echo "Can't Find ATLAS Database, Please check again!";
	}
	$query = "update users set Password='$_passwd',Email='$_email',GroupID='$_group',Description='$_description' where  UserID='$_user_id'";
	$res = mysql_query($query, $dbh);

	//echo mysql_errno().":".mysql_error()."\n";	
	if(!$res){ 
		echo "<p align=center><font color=red size=4>Error,please contact <a href=mailto:shqa@actiontec.com >Automation</a></font></p>"; 
	    	mysql_close($dbh);
	    	setFooter();
	    	exit;
	} else { 
		echo '<center><table border="0" cellspacing="0" cellpadding="0" width=60% height=400>
        	  	<tr><td align="center"><font color=green size=12>Hi '.$_user_id.', updated successfully!</font></td></tr></table></center>';
		mysql_close($dbh);
	    	setFooter();
	    	exit;
	} 

}
/**
 * Display the page of modify user;
 */
if($_GET['action']=="modify"){
	$_user_id=$_GET['user_id'];
	$dbh = dbConnect();
	mysql_select_db("ATLAS",$dbh); 
	/**
	 * Select the user who be modified from databases;;
 	 */
	$query="select * from users where UserID='$_user_id' LIMIT 1";
	$result = mysql_query($query);
	$row_value=mysql_fetch_row($result);
	//echo'<center><H1>Update User Information</H1></center>
	echo '<center> <form method=post action=update_self.php?action=update&user_id='.$row_value[0].'>
	<table width=50%>
		<tr>
			<td width=30% align=right>UserID:</td>
			<td><input readonly="readonly" disabled="disabled" type="text" name="user_id" value='. $row_value[0] .'>&nbsp;&nbsp;</td>
		<tr> 
			<td width=30% align=right>New Password:</td> 
			<td><input type=password name="newpasswd">&nbsp;<font color=red>*</font></td>
		</tr>			
		<tr>
			<td width=30% align=right>Email:</td>
			<td><input type=text maxlength=32 name="email" value='.$row_value[2].'>&nbsp;<font color=red>*</font></td>
		</tr>
		<tr>
			<td width=30% align=right>Group:</td>
			<td><select maxlength=16 name="group" value='.$row_value[3].'>
				<option>Automation</option>
				<option>Manual</option>
				<option>Admin</option>
				</select>
			</td>
		</tr>
		<tr>
			<td align=right>Description:</td>
			<td><textarea wrap=soft name="description" rows=6 cols=19>'.$row_value[4].'</textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr> 
			
	</table>
	<table width=30%>
		<tr>
			<td align=right><input type=submit value="Submit"></td><td align=left><input type=reset value="Reset"></td>
		</tr>
	</table>
	</form>
	</center>';

	mysql_free_result($result);
	mysql_close($dbh);
}
/**
 * Display error info and re-modify when encountered error;
 */
function displayerror($errs,$_user_id,$_passwd,$_email,$_group,$_description)
{
	
	echo '<center><font color=red>'.$errs.'</font></center>';
	echo '<center> <form method=post action=update_self.php?action=update&user_id='. $_user_id .'>
	<table width=50%>
		<tr>
			<td width=30% align=right>UserID:</td>
			<td><input readonly="readonly" disabled="disabled" type="text" name="user_id" value='. $_user_id .'>&nbsp;&nbsp;</td>
		<tr> 
			<td width=30% align=right>New Password:</td> 
			<td><input type=password name="newpasswd">&nbsp;<font color=red>*</font></td>
		</tr>			
		<tr>
			<td width=30% align=right>Email:</td>
			<td><input type=text maxlength=32 name="email" value='.$_email.'>&nbsp;<font color=red>*</font></td>
		</tr>
		<tr>
			<td width=30% align=right>Group:</td>
			<td><select maxlength=16 name="group" value='.$_group.'>
				<option>Automation</option>
				<option>Manual</option>
				<option>Admin</option>
				</select>
			</td>
		</tr>
		<tr>
			<td align=right>Description:</td>
			<td><textarea name="description" rows=6 cols=19>'.$_description.'</textarea></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
		</tr> 
			
	</table>
	<table width=30%>
		<tr>
			<td align=right><input type=submit value="Submit"></td><td align=left><input type=reset value="Reset"></td>
		</tr>
	</table>
	</form>
	</center>';
}
setFooter();
?>

