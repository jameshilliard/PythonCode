<?php
include("./contest/ATLAScom.php");
$_GET['action']=="manage";
	navBar(manage_project);
	session_start();
	//echo session_id();
	//echo $_SESSION['currentUser'];
	$userID = $_SESSION['currentUser'];
	echo "<center><H1>'$userID' Manage Project!</H1></center>";
	setFooter();

?>
