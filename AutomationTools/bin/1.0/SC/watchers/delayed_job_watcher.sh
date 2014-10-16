#!/bin/sh
# chkconfig: 2345 90 10
# description: Runs the Ruby God monitor to watch Delayed Job workers

APP_ROOT=/opt/www/servercontrol

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/ruby/bin
DAEMON=/usr/local/ruby/bin/god
DAEMON_ARGS="-c $APP_ROOT/watchers/delayed_job.watcher"
NAME=delayed_job_watcher
DESC=delayed_job_watcher
PIDFILE=/var/run/delayed_job_watcher.pid

test -x $DAEMON || exit 0
test -x $DAEMONBOOTSTRAP || exit 0

set -e

case "$1" in
  start)
        echo -n "Starting $DESC: "
      $DAEMON $DAEMON_ARGS -P /var/run/god.pid -l /var/log/god.log
      RETVAL=$?
      echo "God started"
    ;;
  stop)
        echo -n "Stopping $DESC: "
      kill `cat /var/run/god.pid`
      kill `ps -e -o pid,command | grep node -m 1 | awk '{ print $1; }'`
      RETVAL=$?
      echo "God stopped"
    ;;

  restart|force-reload)
    ${0} stop
    ${0} start
    ;;
  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload}" >&2
    exit 1
    ;;
esac

exit 0
