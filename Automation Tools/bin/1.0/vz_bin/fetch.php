<?php
/*
   1) This file is used for testing upload operation in TR069
   2) Suggest to deploy it under apache server ROOT dir. /var/www/html/fetch/fetch.php
   3) Open a browser, access this file. http://192.168.10.200/fetch/fetch.php
      You would see a conf file generated under itself diretory

   Change history:
	Acquired from manual test team

   Hugo input 09/25/2010
*/

/* PUT data comes in on the stdin stream */
if(!$putdata = fopen("php://input", "r"))
{	
	echo "Cannot open file input";
	exit;
}
   
/* Open a file for writing */
if(!$fp = fopen("./conf", "w"))
{
	echo "Cannot open file conf";
	exit;
}

/* Read the data 1 KB at a time
   and write to the file */
while ($data = fread($putdata, 1024))
	fwrite($fp, $data);
/* Close the streams */
fclose($fp);
fclose($putdata);
echo "File - conf has been created";
?> 
