#--------------------------------------------------------------
#  Routine_Main.pm
#  Name: Hugo
#  Contact: shqa@actiontec.com
#  Description: This is the main entry subroutine
#
#  Options:
#
#  Copyright @ Actiontec Ltd.
#--------------------------------------------------------------
package Routine_Main;

use Operate_TableJob;
use Get_Firmware;
use strict;

sub debugpurpose {
  my $rest = Operate_TableJob->query_job_tsuite();
  print "$rest\n";
  my $resi = Operate_TableJob->query_job_image();
  print "$resi\n";
}

sub retrive_jobid {
  # testbed number fetch from your system environment
  # So, why not to check ~/.bashrc
  my $dbip = $ENV{'G_DATABASE_SERVER'};
  my $dbuser = 'actiontec';
  my $dbpasswd = 'actiontec';
  my $dbname = 'ATLAS';
  my $dbtable = 'job';
  my $dbtbed = $ENV{'MY_TB'};
  my ($retvalue, $retstr) = Operate_TableJob->query_job_status( $dbip, $dbuser, $dbpasswd, $dbname, $dbtable, $dbtbed);
  return ($retvalue, $retstr); 
}

sub retrive_firmware {
  my ($jobid) = @_;
  my $ftpip = $ENV{'G_FTP_SERVER'};
  my $ftpuser = 'ftp';
  my $ftppasswd = 'ftp';
  my $ftpsubdir = Operate_TableJob->query_job_productid();
  my $ftpprefirmware = Operate_TableJob->query_job_fwversion();
  my $ftpfirmware = Operate_TableJob->query_job_image();
  $ftpfirmware = "$ftpprefirmware"."$ftpfirmware";
  
  
  print "JobID: $jobid\n";
  my $retftp = Get_Firmware->get_firmware($ftpip, $ftpuser, $ftppasswd, $ftpsubdir, $ftpfirmware);
  if ($retftp eq 'true') {
     return 'get_done';
  } else {
     return 'get_fail';
  } 
}

sub launch_newjob {
  my $rootlocation = $ENV{'SQAROOT'};
  my $tsuitelocation = $ENV{'SQAROOT'};
  my $ut_product = Operate_TableJob->query_job_productid();
  my $name_tsuite = Operate_TableJob->query_job_tsuite();
  $name_tsuite .= ".tst";
  my $name_image = Operate_TableJob->query_job_image();
  my $name_fwversion = Operate_TableJob->query_job_fwversion();

  #---------------------------------------------------
  #
  # Launch the BHR2 regression test
  #
  #---------------------------------------------------
  if ( $ut_product =~ m/bhr2/ ) {
      my @ntsuite_stack;
      push @ntsuite_stack, split /_/, $name_tsuite;
      $tsuitelocation = "$tsuitelocation"."/testsuites/1.0/verizon/"."$ntsuite_stack[1]"."/";
 
      if (-e "$tsuitelocation"."$name_tsuite") {
          print "Now start the testing- $name_tsuite\n";
          my $file_firmware = "$name_fwversion"."$name_image";
          system ("/bin/cp $rootlocation/download/$file_firmware $rootlocation/download/MI424WR-GEN2.rmt");
          # e.g aipadlaunch.sh sh_aipad_lan_ether.tst
          # bash file name - tsuite dir name + launch.sh
          # testsuite - testsuite name + .tst, the secondary str is tsuite dir name
          my @execmd = ("killall busyscreen", "busyscreen > /dev/null &", 
                 "bash $tsuitelocation/$ntsuite_stack[1]"."launch.sh"." $name_tsuite");
          my $ret_sys_cmd;
          Operate_TableJob->update_job_starttime();
          foreach (@execmd) {
              print "$_ \n";
              $ret_sys_cmd = system($_);
          }
	  Operate_TableJob->update_job_endtime();
          #$ret_sys_cmd >> 8;
          # ------------------------------------ #
          # return value from $_, 1-fail, 0-pass #
          # ------------------------------------ #  
          #if ($ret_sys_cmd) { 
          #    return 'fail';
          #} else {
          #    return 'done';
          #}
          return 'done';
      } else {
          print "testcase file doesn't exist - $name_tsuite\n";
          return "no_file";
      }
  }

  #----------------------------------------------------
  #
  # Add any other regression test below
  #
  #----------------------------------------------------

}

sub update_status {
  my ($change_status) = @_;
  my $ret_update; 
  SWITCH: {
     $change_status eq 'running' && do { $ret_update = Operate_TableJob->update_job_run_status(); last SWITCH; };
     $change_status eq 'wrong' && do { $ret_update = Operate_TableJob->update_job_wrong_status(); last SWITCH; };
     $change_status eq 'done' && do { $ret_update = Operate_TableJob->update_job_done_status(); last SWITCH; };
  }
  return $ret_update;
}

#-------------------------------------------------------------------------
# Main starts here
#
#-------------------------------------------------------------------------
sub main_routine {
  my ($jobid, $retstr) = retrive_jobid();
  if ($jobid eq "no_new_job") {
     return "no_new_job";
  } 
     elsif ($jobid eq "fail") {
        print "check your database \n";
        return "fail";
     } 
        elsif ($jobid eq "running_job") {
           return ("running_job", $retstr);
        } 
  else {
     my $filelocation = $ENV{'SQAROOT'};
     $filelocation = $filelocation.'download'.'/';
     my $name_image = Operate_TableJob->query_job_image();
     my $name_fwversion = Operate_TableJob->query_job_fwversion(); 
     my $file_firmware = "$name_fwversion"."$name_image";

     # check if the firmware file exists
     if (-e "$filelocation"."$file_firmware") {
         print "Launch the new job\n";
         my $ret_run = update_status('running');
         if ($ret_run ne 'true') {
            print "fail to update running status\n";
            return 'false';
         }
  
         my $ret_launch = launch_newjob();
         if ($ret_launch ne "done") {
             my $ret_done = update_status('wrong');
             if ($ret_done ne 'true') {
                print "fail to update wrong status\n";
                return 'false';
             }
         } else {
             my $ret_done = update_status('done');
             if ($ret_done ne 'true') {
                print "fail to update done status\n";
                return 'false';
             }
         }
     
     } else {
         my $get_firmware = retrive_firmware($jobid);
         if ($get_firmware eq 'get_done') {
             print "Launch the new job\n";
             
             my $ret_run = update_status('running');
             if ($ret_run ne 'true') {
                 print "fail to update running status\n";
                 return 'false';
             }
  
             my $ret_launch = launch_newjob();
             if ($ret_launch ne "done") {
                 my $ret_done = update_status('wrong');
                 if ($ret_done ne 'true') {
                     print "fail to update wrong status\n";
                     return 'false';
                 } 
             } else {
                 my $ret_done = update_status('done');
                 if ($ret_done ne 'true') {
                     print "fail to update done status\n";
                     return 'false';
                 }
             }       
  
         } else {
             print "there is an error, check the firmware file you are loading\n";
             my $ret_wrong = update_status('wrong');
             if ($ret_wrong ne 'true') {
                 print "fail to update wrong status\n";
                 return 'false';
             }
         }
     }
  }
  print "The End\n";
  return 'true';
}

1;


