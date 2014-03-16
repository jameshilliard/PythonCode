#--------------------------------------------------------------
#  Operate_TableJob.pm
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
#  Table Job structure:
#          +-----------+--------------+------+-----+-------------------+-------+
#          | Field     | Type         | Null | Key | Default           | Extra |
#          +-----------+--------------+------+-----+-------------------+-------+
#          | JobID     | varchar(18)  | NO   | PRI | NULL              |       | 
#          | TbedID    | varchar(50)  | NO   |     | NULL              |       | 
#          | ProductID | varchar(50)  | NO   |     | NULL              |       | 
#          | FWVersion | varchar(50)  | NO   |     | NULL              |       | 
#          | Image     | varchar(200) | NO   |     | NULL              |       | 
#          | Tsuite    | varchar(50)  | NO   |     | NULL              |       | 
#          | Status    | int(2)       | NO   |     | NULL              |       | 
#          | SubTime   | timestamp    | NO   |     | CURRENT_TIMESTAMP |       | 
#          | StartTime | timestamp    | YES  |     | NULL              |       | 
#          | EndTime   | timestamp    | YES  |     | NULL              |       | 
#          | UserID    | varchar(50)  | NO   |     | NULL              |       | 
#          +-----------+--------------+------+-----+-------------------+-------+
#
#  Copyright @ Actiontec Ltd.
#--------------------------------------------------------------
package Operate_TableJob;

use DBI;
use strict;

my $tablejob_ref;
my ($dsnip, $user, $password, $dbname, $ntable, $dbtbed);

sub query_job_status {
  shift @_;
  ($dsnip, $user, $password, $dbname, $ntable, $dbtbed) = @_;
  
  if (! defined $dsnip) {
    $dsnip = "192.168.10.133";
    print "To have a default database server ip:$dsnip\n";
  }
  if (! defined $user) {
    $user = "actiontec";
    print "To have a default database login username:$user\n";
  }
  if (! defined $password) {
    $password = "actiontec";
    print "To have a default database login password:$password\n";
  }
  if (! defined $dbname) {
    $dbname = "ATLAS";
    print "To have a default database:$dbname\n";
  }
  if (! defined $ntable) {
    $ntable = "job";
    print "To have a default table name:$ntable\n";
  }
  if (! defined $dbtbed) {
    $dbtbed = "tb21";
    print "To have a default testbed:$dbtbed\n";
  }

  # --------------------------------------------------------- 
  # Status equal to 0 means a new job
  #                 1 means a running job
  #                 2 means a pass job
  #                 3 means a fail job
  #                 4 means a wrong job
  # ---------------------------------------------------------
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die "Couldn't connect to database: ".DBI->errstr;

  # ----------------------------------------------------------------
  # To check whether there exists a stamp of running job in database

  my $statement_runjob = "select * from $ntable where TbedID='$dbtbed' and Status=1"; 
  my $tablejob_runjob_ref = $dbh->selectrow_arrayref(
	  $statement_runjob,
	  { Slice => {} }
  );
  if ($tablejob_runjob_ref) {
      my $statement_update_wrong = "update $ntable set Status=4 where JobID='$$tablejob_runjob_ref[0]'";
      $dbh->do($statement_update_wrong);
      $dbh->disconnect;
      return ('running_job', $$tablejob_runjob_ref[0]);
  }
  #
  # ----------------------------------------------------------------

  my $statement = "select * from $ntable where TbedID='$dbtbed' and Status=0";
  $tablejob_ref = $dbh->selectrow_arrayref(
          $statement,
          { Slice => {} }
  );
  $dbh->disconnect;
  
  if (! $tablejob_ref) {
      return 'no_new_job';
  } else {
      #print "The JobID: $$tablejob_ref[0]\n";
      return "$$tablejob_ref[0]";
  }
}

sub query_job_productid {
  if (! $tablejob_ref) {
      return 'no_new_job';
  } else {
      return "$$tablejob_ref[2]";
  }
}

sub query_job_fwversion {
  if (! $tablejob_ref) {
      return 'no_new_job';
  } else {
      return "$$tablejob_ref[3]";
  }
}

sub query_job_image {
  if (! $tablejob_ref) {
      return "no_new_job";
  } else {
      return "$$tablejob_ref[4]";
  }
}

sub query_job_tsuite {
  if (! $tablejob_ref) {
      return "no_new_job";
  } else {
      return "$$tablejob_ref[5]";
  }
}

sub update_job_run_status {
  if (! $tablejob_ref) {
      return "no_new_job";
  }

  my $index_jobid = $$tablejob_ref[0];    
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die ("Couldn't connect to database: " . DBI->errstr);
  my $statement = "update $ntable set Status=1 where JobID='$index_jobid'";
  $dbh->do($statement);
  $dbh->disconnect;
 
  return 'true';
}

sub update_job_done_status {
  if (! $tablejob_ref) {
      return "no_new_job";
  }

  my $index_jobid = $$tablejob_ref[0];    
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die ("Couldn't connect to database: " . DBI->errstr);
  my $statement = "update $ntable set Status=2 where JobID='$index_jobid'";
  $dbh->do($statement);
  $dbh->disconnect;
 
  return 'true';
}

sub update_job_wrong_status {
  if (! $tablejob_ref) {
      return "no_new_job";
  }

  my $index_jobid = $$tablejob_ref[0];    
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die ("Couldn't connect to database: " . DBI->errstr);
  my $statement = "update $ntable set Status=3 where JobID='$index_jobid'";
  $dbh->do($statement);
  $dbh->disconnect;
 
  return 'true';
}

sub update_job_starttime {
  if (! $tablejob_ref) {
      return "no_new_job";
  }
   
  my $index_jobid = $$tablejob_ref[0];    
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die ("Couldn't connect to database: " . DBI->errstr);
#  my $start_time = `date +%Y%m%d%H%M%S`;
#  chomp($start_time);
  my $statement = "update $ntable set StartTime=now() where JobID='$index_jobid'";
  $dbh->do($statement);
  $dbh->disconnect;
  
  return 'true';
}

sub update_job_endtime {
  if (! $tablejob_ref) {
      return "no_new_job";
  }

  my $index_jobid = $$tablejob_ref[0];    
  my $dsn = "DBI:mysql:database=$dbname;host=$dsnip";  
  my $dbh = DBI->connect($dsn, $user, $password, { RaiseError =>1, PrintError => 0 }) or die ("Couldn't connect to database: " . DBI->errstr);
#  my $end_time = `date +%Y%m%d%H%M%S`;
#  chomp($end_time);
  my $statement = "update $ntable set EndTime=now() where JobID='$index_jobid'";
  $dbh->do($statement);
  $dbh->disconnect;

  return 'true';
}

1;

