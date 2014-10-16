#--------------------------------------------------------------
#  Operate_TableTestResult.pm
#  Name: Hugo
#  Contact: shqa@actiontec.com
#  Description: This package is to query status in job table
#
#  Make sure your system installed:
#                    yum install mysql
#                    yum install perl-DBD-MySQL.i386
#                    perl -MCPAN -e"force install DBI"
#                    perl -MCPAN -e"force install DBD::mysql"
#
#  Options:
#          dsnip:	database ip address
#          user:	database operation user name
#          password:	database operation password
#          dbname:	database name
#          ntable:	operation table name
#          dbtbed:	testbed name
#
#  Table structure:        
#          +----------+--------------+------+-----+-------------------+-------+
#          | Field     | Type         | Null | Key | Default           | Extra |
#          +-----------+--------------+------+-----+-------------------+-------+
#          | JobID     | varchar(18)  | NO   | PRI | NULL              |       | 
#          | TcaseID   | varchar(50)  | NO   | PRI | NULL              |       | 
#          | Result    | int(2)       | NO   |     | NULL              |       | 
#          | BugID     | varchar(50)  | YES  |     | NULL              |       | 
#          | Comments  | varchar(200) | YES  |     | NULL              |       | 
#          | Log       | varchar(400) | YES  |     | NULL              |       | 
#          | Duration  | int(11)      | YES  |     | NULL              |       | 
#          | StartTime | timestamp    | NO   |     | CURRENT_TIMESTAMP |       | 
#          +-----------+--------------+------+-----+-------------------+-------+
#
#  Copyright @ Actiontec Ltd.
#--------------------------------------------------------------
package Gfdaemon::Operate_TableTestResult;

use DBI;
use strict;

my $tablejobid_ref;
my ($dsnip_tresult, $user_tresult, $password_tresult, $dbname_tresult, $ntable_tresult, $dbtbed_tresult);
my ($dbh_tresult, $dsn_tresult);

sub conn_db {
  shift @_;
  ($dsnip_tresult, $user_tresult, $password_tresult, $dbname_tresult, $ntable_tresult, $dbtbed_tresult) = @_;
  
  if (! defined $dsnip_tresult) {
    $dsnip_tresult = "192.168.10.133";
    print "To have a default database server ip:$dsnip_tresult\n";
  }
  if (! defined $user_tresult) {
    $user_tresult = "actiontec";
    print "To have a default database login username:$user_tresult\n";
  }
  if (! defined $password_tresult) {
    $password_tresult = "actiontec";
    print "To have a default database login password:$password_tresult\n";
  }
  if (! defined $dbname_tresult) {
    $dbname_tresult = "ATLAS";
    print "To have a default database:$dbname_tresult\n";
  }
  if (! defined $ntable_tresult) {
    $ntable_tresult = "testresult";
    print "To have a default table name:$ntable_tresult\n";
  }
  if (! defined $dbtbed_tresult) {
    $dbtbed_tresult = $ENV{'MY_TB'};
    print "To have a default testbed:$dbtbed_tresult\n";
  }

  # --------------------------------------------------------- 
  # Status equal to 0 means a new job
  #                 1 means a running job
  #                 2 means a done job
  #                 3 means a wrong job
  # ---------------------------------------------------------
  $dsn_tresult = "DBI:mysql:database=$dbname_tresult;host=$dsnip_tresult";  
  $dbh_tresult = DBI->connect($dsn_tresult, $user_tresult, $password_tresult, { RaiseError =>1, PrintError => 0 }) or die "Couldn't connect to database: ".DBI->errstr;
  my $statement_tresult = "select * from job where TbedID='$dbtbed_tresult' and Status=1";
  $tablejobid_ref = $dbh_tresult->selectrow_arrayref(
        $statement_tresult,
        { Slice => {} }
  );

}

sub dis_conn_db {
  $dbh_tresult->disconnect;
}

sub query_runjobid {

print "$dbh_tresult\n";
  if (! $tablejobid_ref) {
      return 'no_run_job';
  } else {
      return "$$tablejobid_ref[0]";
  }
}

sub query_tcresult {
  if (! $tablejobid_ref) {
      return "no_run_job";
  } else {
      my $statement = "select * from $ntable_tresult where JobID='$$tablejobid_ref[0]'";
      my $query_ref = $dbh_tresult->selectrow_arrayref(
	      $statement,
	      { Slice => {} }
         );
      return $$query_ref[2];
  }
}

sub insert_tcresult {
  if (! $tablejobid_ref) {
      return "no_run_job";
  }

  shift @_;
  my ($tc_id, $run_result, $bug_id, $tc_comment, $tc_log, $tc_duration) = @_;

  my $index_jobid = $$tablejobid_ref[0];    
  my $statement = "insert into testresult(JobID, TcaseID, Result, BugID, Log, Duration, StartTime, Comments) values('$index_jobid', '$tc_id', $run_result, '$bug_id', '$tc_log', '$tc_duration', now(), '$tc_comment')"; 
  $dbh_tresult->do($statement);
  return 'true';
}


1;

