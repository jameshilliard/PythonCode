
<?php
	/****************************************************************************************
 * File Name	: ATLAScommon.php
 * Description	: Load core functions for ATLAS such as html header footer, mysql connection 
 * Author	: Jing Ma
 * Copyright	: 
 * Project	: ATLAS
 * OS		: Linux
 * Date		: 2010-03-25
 ****************************************************************************************/
 /****************************************************************************************
 *
 * Subroutines
 *
 ****************************************************************************************/
include("config.php");
// --------------------------------------------------------------------------------
/**
   * Function start session;
 */
function doSessionStart()
{
        session_set_cookie_params(99999);
        session_save_path('/home/aleon');
        if(!isset($_SESSION)){
                session_start();
        }
}
// --------------------------------------------------------------------------------
/**
 * Function redirect page to another one;
 *
 * @param string URL of required page
 * @param string Brower location - use for redirection for refresh of another frame
 *                                                      Default: 'location'
 */
function redirect($path,$level = 'location')
{
        echo "<html><head></head><body>";
        echo "<script type='text/javascript'>";
        echo "$level.href='$path';";
        echo "</script></body></html>";
        exit;
}
// --------------------------------------------------------------------------------
/**
 * Function set navigation bar;
 */
function navBar($title)
        {
        echo '<html>
              <head>';
       		//doSessionStart();
		session_start();
        	$userID = $_SESSION['currentUser'];
                if(!$userID) {redirect("index.php");}

		echo '<title>'.$title.'</title>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                        <meta http-equiv="Content-language" content="en">
			<style type="text/css">
			a{color:}a:hover{color:red} 
			a{TEXT-DECORATION:none} 
		.STYLE1 {color: #0000FF}
				body{
					background-image:url("./image/bg1.jpg");
					background-repeat:repeat-x;
					background-attachment:scroll;
					height:100%;
				}
			</style>
                </head>

                <body>
                <center> <img border = 0 src = "./image/logo_tag.gif"> </center>
                <center><table border=0 cellspacing="0" cellpadding="0" width=800>
                <tr>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./job_submit.php"><font color=white>Submit</font></a></th>
                        
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./status.php"><font color=white>Status</font></a></th>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./job_list.php?index=1"><font color=white>Result</font></a></th>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./administer.php"><font color=white>Admin</font></a></th>
                         <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./manage_users.php"><font color=white>User</font></a></th>
                        <th align="" style="margin: 0px 3px 0px 0px"> </th>
                        <th align="right" style="margin: 0px 3px 0px 0px"><font color=olive>CurrentUser:</font><a href="register/update_self.php?action=modify&user_id='.$userID.'">'.$userID.'</a></th>
                        <th align="right" style="margin: 0px 3px 0px 0px">
                                <a href="./logout.php"><font color=olive>Logout</font></a></th>
                </tr></table></center>
                <hr width=800>';
        }
function registerNavBar($title)
        {
        echo '  <html>
                <head>';

//        	doSessionStart();
		session_start();
        	// echo $_SESSION['currentUser'];
        	$userID = $_SESSION['currentUser'];
                if(!$userID){redirect("index.php");}

	        echo '<title>'.$title.'</title>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                        <meta http-equiv="Content-language" content="en">
                        <style type="text/css">
                        a{color:}a:hover{color:red} 
												a{TEXT-DECORATION:none} 
												.STYLE1 {color: #0000FF}
                                body{
                                        background-image:url("../image/bg1.jpg");
                                        background-repeat:repeat-x;
                                        background-attachment:scroll;
                                        height:100%;
                                }
                        </style>

                </head>

                <body>
                <center> <img border = 0 src = "../image/logo_tag.gif"> </center>
                <center><table border=0 cellspacing="0" cellpadding="0" width=800>
                <tr>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="../job_submit.php"><font color=white>Submit</font></a></th>
                        
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="../status.php"><font color=white>Status</font></a></th>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="../job_list.php?index=1"><font color=white>Result</font></a></th>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="./administer.php"><font color=white>Admin</font></a></th>
                        <th align="left" style="margin: 0px 3px 0px 0px">
                                <a href="../manage_users.php"><font color=white>User</font></a></th>
                        <th align="" style="margin: 0px 3px 0px 0px"> </th>
                        <th align="right" style="margin: 0px 3px 0px 0px"><font color=olive>CurrentUser:</font><a href="./update_self.php?action=modify&user_id='.$userID.'">'.$userID.'</a></th>
                        <th align="right" style="margin: 0px 3px 0px 0px">
                                <a href="../logout.php"><font color=olive>Logout</font></a></th>
                </tr></table></center>
                <hr width=800>';
        }


	function setRefreshHeader($title,$surl="./")
	{
		echo'<html>
		<head>
			<title>'.$title.'</title>
			<meta http-equiv="refresh" content="5; url='.$surl.'">
                        <style type="text/css">
                                body{
                                        background-image:url("./image/bg1.jpg");
                                        background-repeat:repeat-x;
                                        background-attachment:scroll;
                                        height:100%;
                                }
                        </style>

		</head>

		<body>
		<center> <img border = 0 src = "./image/logo_tag.gif"> </center>
		<hr width=800>';
		}

	function setHeader($title)
		{
		session_start();
   		$userID = $_SESSION['currentUser'];
		echo'<html>
		<head>
			<title>'.$title.'</title>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
                        <meta http-equiv="Content-language" content="en">
                        <style type="text/css">
                                body{
                                        background-image:url("./image/bg1.jpg");
                                        background-repeat:repeat-x;
                                        background-attachment:scroll;
                                }
                        </style>
                </head>


		<body>
		<center> <img border = 0 src = "./image/logo_tag.gif"> </center>
		<hr width=800>';
	}

	function setFooter()
	{
		echo'<hr width=800><center>
		<table width=100% border=0>
		<tr>
			<td align=center width=65%><a href = "./"><font color=blue face="Verdana">ATLAS Management System</font></a>
			</td>
		</tr>
		<tr>
		<td align=center width=65%><font face="Verdana">Copyright &copy; 2010,Actiontec Electronics, Inc.  
			</font></td>
		</tr>
			<tr>
		<td align=center width=65%><font face="Verdana">All Rights Reserved  
			</font></td>
		</tr>
		</table>
	</center>
	</body>
	</html>
	</style>';
	}

	function dbConnect(){
	 $dbh = mysql_connect('localhost', 'actiontec', 'actiontec');

	 if(!$dbh)
	  {
		 echo 'Error: Could not connect to database.  Please try again later.';
		 exit;
	  }

	  return $dbh;
	}

	function  reverseCompare($a,$b)   {   
		if($a[2]   ==   $b[2])   return   0;
		return   $a[2]   <   $b[2] ? -1:1; 
	}   

	function forbidRefresh($second)
	{
		session_start();   
	  
		$f5_second=$_SESSION["f5_second"];   
	  
		$now_date=date("H-i-s");   
	  
		$now_second=split("-",$now_date);   
	  
		$old_second=split("-",$f5_second);    
	  
		$max_value=max($now_second[2],$old_second[2]);   
	 
		$min_value=min($now_second[2],$old_second[2]);   
		
	  
		if(   ($max_value   -   $min_value   )   <= $second   )   
	  
		{   
			ojheader("Status");
			echo   '<center><H1>Sorry!Can\'t refresh in '.$second.' second!</H1></center>';
			ojfooter();
			exit;   
		}    
	  
		$now_date=date("H-i-s");   
	  
		$_SESSION["f5_second"]=$now_date;

	}

	function ftpGet($ftp_server,$ftp_user_name,$ftp_user_pass,$destination_file,$source_file){
		$conn= ftp_connect($ftp_server);
		if (!$conn)
			return false;
		if (!ftp_login($conn, $ftp_user_name, $ftp_user_pass)){
			ftp_close($conn);
			return false;
		}

		if(! ftp_get($conn, $source_file,$destination_file,FTP_BINARY)){
			ftp_close($conn);
			return false;
		}
		
		ftp_close($conn);
		return true;
	}

	function ftpPut($ftp_server,$ftp_user_name,$ftp_user_pass,$destination_file,$source_file){

		$conn= ftp_connect($ftp_server);
		if (!$conn)
			return false;
		if (!ftp_login($conn, $ftp_user_name, $ftp_user_pass)){
			ftp_close($conn);
			return false;
		}
		
		if(! ftp_put($conn, $destination_file, $source_file, FTP_BINARY)){
			ftp_close($conn);
			return false;
		}
		
		ftp_close($conn);
		return true;
	}
?>
