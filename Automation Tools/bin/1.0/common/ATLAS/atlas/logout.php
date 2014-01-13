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
 * File Name	: logout.php,v $
 * Description	: logout from ATLAS GUI.
 *
 * Copyright	: @1999-2010 Actiontec Electronics, Inc. 
 * Project	: ATLAS
 * Author	: Aleon
 * @version $Revision: 1.0
 * Date		: 2010-04-07
 ****************************************************************************************/
include("ATLAScom.php");
/**
 * excute operating of logout;
 */
session_start();

$userID = $_SESSION['currentUser'] ? $_SESSION['currentUser'] : null;
if ($userID)
{
	//echo $_SESSION['currentUser'];
	session_unset($_SESSION['currentUser']);
	session_unregister($_SESSION['currentUser']);
	session_destroy();
}

redirect('index.php');
?>


