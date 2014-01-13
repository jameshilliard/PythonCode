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
 * File Name	: create_user.php,v $
 * Description	: The file is used to create user.
 *
 * Copyright	: @1999-2010 Actiontec Electronics, Inc. 
 * Project	: ATLAS
 * Author	: Aleon
 * @version $Revision: 1.0
 * Date		: 2010-04-07
 ****************************************************************************************/
include("../ATLAScom.php");
if($_GET['action']=="register"){
   
	$_confirm=$_POST['confirm'];
	$_passwd=$_POST['passwd'];
	$_group=$_POST['group'];
	$_user_id=$_POST['user_id'];
	$_email=$_POST['email'];
	$_description=$_POST['description'];

	/**
	 * Verify if the infomation of register user is valid;
	 */
        $cid = "Please Check again";

        if(strlen(trim($_user_id))==0){
		registerNavBar("Register Result");
                displayerror("'USERID' should not be null!", $cid);
                setFooter();
                exit;
        }
        if(strlen(trim($_passwd))==0){
		registerNavBar("Register Result");
                displayerror("'Password' should not be null!", $cid);
                setFooter();
                exit;
        }
        if(strlen(trim($_confirm))==0){
		registerNavBar("Register Result");
                displayerror("'Password' should not be null!", $cid);
                setFooter();
                exit;
        }
        if($_passwd!=$_confirm){
		registerNavBar("Register Result");
                displayerror("Please confirm your 'Confirm Password'!", $cid);
                setFooter();
                exit;
        }
        if(strlen(trim($_email))==0){
		registerNavBar("Register Result");
                displayerror("'EMAIL' should not be null!", $cid);
                setFooter();
                exit;
        }

    account($_user_id,$_passwd,$_confirm,$_group,$_email,$_description);
}
else display();

    
    /**
     * The function is for creating user in databases;
     */
function account($_user_id,$_passwd,$_confirm,$_group,$_email,$_description)
{
	registerNavBar("Register Result");
	$dbh = dbConnect();
	$select_db = mysql_select_db("ATLAS",$dbh); 
	if (!$select_db) {
   		 echo "Can't Find ATLAS Database, Please check again!";
	}
	$query1 ="select * from users where UserID='$_user_id'";
	$result1 = mysql_query($query1);
	$num_results = mysql_num_rows($result1);
	/**
	 * Verify if there is reduplicate user in databases;
 	 */
	if($num_results>0){
    		displayerror($_user_id.' has been registered!Please choose another one.');
	    	mysql_close($dbh);
	    	setFooter();
	    	exit;
	}
	$query ="insert into users (UserID,PassWord,Email,GroupID,Description) values ('$_user_id','$_passwd','$_email','$_group','$_description')";
	$res = mysql_query($query, $dbh);
	/**
	 * echo mysql_errno().":".mysql_error()."\n";
	 */
	$err = mysql_error();
	if($err){ 
	   	echo "<p align=center><font color=red size=4>Error,please contact <a href=mailto:shqa@actiontec.com >Automation</a></font></p>"; 
		mysql_close($dbh);
		setFooter();
		exit;
		} else { 
			echo '<center><table border="0" cellspacing="0" cellpadding="0" width=60% height=400>
				<tr><td align="center"><font color=green size=12><a href="./../manage_users.php">Hi '.$_user_id.',you have registered successfully!					</a></font></td></tr></table></center>';
			mysql_close($dbh);
	    		setFooter();
	    		exit;
		} 
}
/**
 * The function is for display error message when encounter register issue;
 */
function displayerror($errs)
{
	echo '<center><font color=red>'.$errs.'</font></center>';
	echo '<center><H1>Register</H1></center>';
	echo '<center>
		<form method=post action=create_user.php?action=register>';
	echo "<table width=50%>
		<tr>
			<td width=30% align=right>UserName:</td>
			<td><input type=text maxlength=16 name='user_id'>&nbsp;<font color=red>*</font></td>			
		</tr>
		<tr>
	    		<td width=30% align=right>Password:</td>
			<td><input type=password maxlength=16 name='passwd'>&nbsp;<font color=red>*</font></td>
		</tr>
		<tr>
			<td align=right>Confirm Passwd:</td>
			<td><input type=password maxlength=16 name='confirm'>&nbsp;<font color=red>*</font></td>
		</tr>
		<tr>
			<td width=30% align=right>Email:</td>
			<td><input type=text maxlength=32 name='email'>&nbsp;<font color=red>*</font></td>
		</tr>
		<tr>
			<td width=30% align=right>Group:</td>
			<td><select maxlength=16 name='group'>
				<option>Automation</option>
				<option>Manual</option>
				<option>Admin</option>
				</select>
			</td>
		</tr>
		<tr>
			<td align=right>Description:</td>
			<td><textarea wrap=soft name='description' rows=6 cols=19></textarea></td>
		</tr>
		</table>
		<table width=30%>
		<tr>
			<td align=left><input type=submit value='Submit'></td><td align=left><input type=reset value='  Reset  '></td>
			<td align=left><input name='cancel' value='Cancel' type='button' onclick='javascript: location.href=\".\/..\/manage_users.php\"'></td>			
		</tr>
		</table>
		<input name=op id=op type=hidden value=register>
		</form>
		</center>";
    }
    /**
     * The function is for display the page of create users;
     */
    function display()
    {
		registerNavBar("Register");
		echo '<center><H1><font color=blue>Register</font></H1></center>';
		echo '<center>
		<form method=post action=create_user.php?action=register>';
		echo "<table width=50%>
			<tr>
				<td width=30% align=right>UserName:</td>
				<td><input type=text maxlength=16 name='user_id'>&nbsp;<font color=red>*</font></td>	
			</tr>
			<tr>
				<td width=30% align=right>Password:</td>
				<td><input type=password maxlength=16 name='passwd'>&nbsp;<font color=red>*</font></td>
			</tr>
			<tr>
				<td align=right>Confirm Passwd:</td>
				<td><input type=password maxlength=16 name='confirm'>&nbsp;<font color=red>*</font></td>
			</tr>
			<tr>
				<td width=30% align=right>Email:</td>
				<td><input type=text maxlength=32 name='email'>&nbsp;<font color=red>*</font></td>
			</tr>
			<tr>
				<td width=30% align=right>Group:</td>
				<td><select maxlength=16 name='group'>
				    <option>Automation</option>
				    <option>Manual</option>
				    <option>Admin</option>
				    </select>
				</td>
			</tr>
			<tr>
				<td align=right>Description:</td>
				<td><textarea wrap=soft name='description' rows=6 cols=19></textarea></td>
			</tr>
		</table>
		<table width=20%>
			<tr>
				<td align=left><input type=submit value='Submit'></td><td align=left><input type=reset value='Reset'></td>
				<td align=left><input name='cancel' value='Cancel' type='button' onclick='javascript: location.href=\".\/..\/manage_users.php\"'></td>
			</tr>
		</table>
		</form>
		</center>";
}
setFooter();
?>
