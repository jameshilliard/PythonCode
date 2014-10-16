<?php
include("./ATLAScom.php");
//header
 setheader("ATLAS Management System");
 echo '<table width=800 height=600 border=0 align=center><tr  height=100><td ><font size="+3" color=black face="Verdana"><center>ATLAS Management System</center></font></td></tr>';
echo '
<tr height=60><td><center><font size="+3" color=red face="Verdana"><a href = "tb_status.php">Testbed Status</a></font></center></td></tr>
<tr height=60><td><center><font size="+3" color=red face="Verdana"><a href = "job_submit.php">Job Submission</a></font></center></td></tr>
<tr height=60><td><center><font size="+3" color=red face="Verdana"><a href = "result_query.php">Result Query</a></font></center></td></tr>
<tr height=60><td><center><font size="+3" color=red face="Verdana"><a href = "register.php">Register</a></font></center></td></tr>
<tr height=60><td><center><font size="+3" color=red face="Verdana"><a href = "./admin/index.php">Administration</a></font></center></td></tr>
<tr height=100><td>&nbsp</td></tr></table>';


setfooter();
?>
