#-------------------------------------------------------------------
#  tbdaemon.pl
#  Name: Hugo
#  Contact: shqa@actiontec.com
#  Description: It runs on the master PC on one testbed. It queries 
#      database every a range of time. It would wake up a testing auto-
#      matically based on the status on the job table. 
#  Options:
#
#  Copyright @ Actiontec Ltd.
#-------------------------------------------------------------------
#! /usr/bin/perl -w

use Routine_Main;
use Proc::ProcessTable;
use POSIX ":sys_wait_h";
use strict;

sub syschk_this {
  my $t_thisproc = new Proc::ProcessTable;
  my $count_thisproc = 0;
  foreach my $p (@{$t_thisproc->table}) {
     if ($p->cmndline =~ /tbdaemon/) {
	 $count_thisproc += 1;
     } 
  }
  if ($count_thisproc > 1) {
      print "Ooops! there already has a tbdaemon running.........\n\n";
      print "\tYou have two choices:\n";
      print "\t\t1) Stop to start a new one\n";
      print "\t\t2) Kill the previous one, then execute tbdaemon again\n\n";
      exit 0;
  }

}

sub sysclean_gf {
  my $t_sysproc = new Proc::ProcessTable;
  foreach my $p (@{$t_sysproc->table}) {
     if ($p->cmndline =~ /gflaunch/) {
       kill 9, $p->pid;
     }
  }
}

#-------------------------------------------------------------------
#  Start:
#
#-------------------------------------------------------------------
syschk_this();
sysclean_gf();
my $childpid = fork();
die "Cannot fork: $!" unless defined $childpid;

if ($childpid > 0 ) {
    my $kid;
    do {
	 $kid = waitpid(-1, WNOHANG);
    } while ($kid > 0);
    exit(0);
} else {
    my $cmd = "ps aux | grep gflaunch | grep -v grep"; 
    while(1) {
	my $result = system($cmd);
	if ($result == 0) {
            print "Oh! NO~~ a running test might not finish yet..........\n";
	    sleep 600;
	} else {
            my ($ret_routine_main, $daem_retstr) = Routine_Main->main_routine();
            if ($ret_routine_main eq 'no_new_job') {
		print "hey lucky guy! might not have a running test now........\n";
                sleep 600;
	    } elsif ($ret_routine_main eq 'running_job') {
                print "\n\n\n\tDetected there is a RUNNING STATUS job. The Job ID - $daem_retstr\n";
		print "\tIt might be caused by an unexpected damaged exit\n\tor a power-off in previous running\n";
		print "\tAnyway, this issue job was tagged as a WRONG, Next new Job would be called in short minutes\n\n\n";
		sleep 600;
	    }
	}
    }
	
}

