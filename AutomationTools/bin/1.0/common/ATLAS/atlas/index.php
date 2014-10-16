
<?php
/* **************************************************************************************
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
 *
 * File Name	: index.php
 * Description	: The file is for user login ATLAS automation platform; 
 *
 * Copyright	: @1999-2010  
 * Project	: ATLAS
 * Author	: Aleon
 * Date		: 2010-03-25
 **************************************************************************************/
include("ATLAScom.php");

/**
* load header file;
**/
setHeader("ATLAS Login Page");
if($_GET['action']=="auth"){
   
	$_user_id=$_POST['user_id'];
	$_passwd=$_POST['passwd'];

	//echo "info :'$_user_id','$_passwd'";

        if(strlen(trim($_user_id))==0){
                displayerror("'User Name' can not be Null");
                setFooter();
                exit;
        }

	auth($_user_id,$_passwd);

} else login();
/**
 * Authenticate the user of login;
 **/
function auth($_user_id,$_passwd)
{
	session_start();
	//unset($_SESSION['basehref']);
	session_register();
	$_SESSION['currentUser'] = $_user_id;
	//echo $_SESSION['currentUser'];
	/**
	* connection database and auth user;
	**/	
	$dbh = dbConnect();
	$select_db = mysql_select_db("ATLAS",$dbh); 
	if (!$select_db) {
		echo "Can't Find ATLAS Database, Please check again!";
	}
	$query ="select * from users where UserID='$_user_id' and Password='$_passwd' LIMIT 1";
	
	$result = mysql_query($query);
	$num_rs = mysql_num_rows($result);
	/**
	**/
	if($num_rs > 0) {
		echo '<script language="javascript">
		window.location="status.php";	
	   	 </script>';	
	} else {
		displayerror('Try again! Wrong UserID or Password.');
		mysql_close($dbh);
	    	setFooter();
	    	exit;
	}

}
/**
* Display the error info and re-login when login fail;
**/	
function displayerror($err)
{
	echo '<center><font color=red>'.$err.'</font></center>';
	//echo '<center><H1>Authentication</H1></center>';
	echo '<center>
	<form autocomplete=off method=post action=index.php?action=auth>
	<table width=40% border=0>
		<tr height=80>
			<td> </td>
		</tr>
		<tr>
			<td width=35% align=right><b>UserID:</b></td>
			<td><input type=text maxlength=16 name="user_id" style="width:100px;height:20px;"></td>
		</tr>
		<tr height=10>
			<td> </td>
		</tr>
		<tr>
			<td width=35% align=right><b>Password:</b></td>
			<td><input type=password name="passwd" style="width:100px;height:20px;"></td>
		</tr>
		<tr height=30>
			<td> </td>
		</tr>
		</table>';
					//<form method=post action=create_user.php?action=register>
			//<td align=left><input type=submit value=" Register " name="Register"></td></form></tr>
		echo '<table width=18%>
		<tr>
			<td align=left><input type=submit value=" Login " name=" Login "></td>
			<td align=left><input type=reset value=" Reset " name="Reset"></td></form>
		<tr height=140>
			<td> </td>
		</tr>
		</table>
	</center>';
    }

/**
* Display the login page;
**/	
function login()
{


	echo '<center><font color=white><h1>ATLAS AUTOMATION PLATFORM</h1></font></center>
	<center>
	<form autocomplete=off  method=post action=index.php?action=auth>
	<table width=40% border=0>
		<tr height=80>
			<td> </td>
		</tr>
		<tr>
			<td width=35% align=right><b>UserID:</b></td>
			<td><input type=text  name="user_id"  style="width:100px;height:20px;" ></td>
		</tr>
		<tr height=10>
			<td> </td>
		</tr>
		<tr>
			<td width=35% align=right><b>Password:</b></td>
			<td><input type=password name="passwd" style="width:100px;height:20px;" ></td>
		</tr>
		<tr height=30>
			<td> </td>
		</tr>
		</table>';
		echo "<table border=0 width=18%>
		<tr>
			<td align=left><input type=submit value=' Login ' name=' Login '></td>
			
			<td align=left><input type=reset value=' Reset ' name='Reset'></td>
			</form>
		</tr>
		<tr height=140>
			<td> </td>
		</tr>
	</table>
	</center>";
}

setFooter();
?>
