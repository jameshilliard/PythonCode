#!/usr/bin/env python
# coding=utf-8
import os, sys, re, threading
import time, datetime
from multiprocessing import Process, Queue, Lock, Value, Array, Manager

from pprint import pprint, pformat


class Timed_Job(Process):
    _last_error = ''
    d = {}

    def setup(self, first_delay=0, interval=60, max_count=-1, exit_successive_failure=-1, exit_sum_failure=-1):
        """
        """
        self._first_delay = first_delay
        self._exitcode = 0
        # self.last_error = ''
        self._sleep_interval = 1
        self._timer_interval = interval
        self._last_on_time = time.time() + self._timer_interval

        self._loop_count = 0
        self._max_count = max_count

        self._exit_successive_failure = exit_successive_failure
        self._exit_sum_failure = exit_sum_failure

        self._successive_failure = 0
        self._sum_failure = 0
        pass


    def run(self):
        print('[%s] run %s' % (datetime.datetime.now(), self.name))
        # self.setup()
        rc = 0
        first_delay = self._first_delay
        while 1:

            if self._max_count > 0 and self._loop_count >= self._max_count:
                self._last_error = 'expired max count %s' % self._max_count
                self._exitcode = 0
                break

            if self._exit_successive_failure > 0 and self._successive_failure >= self._exit_successive_failure:
                self._last_error = 'exit due to successive failure more than %s' % self._exit_successive_failure
                self._exitcode = self._successive_failure
                break

            if self._exit_sum_failure > 0 and self._sum_failure >= self._exit_sum_failure:
                self._last_error = 'exit due to sum failure more than %s' % self._exit_sum_failure
                self._exitcode = self._sum_failure
                break

            if first_delay < 0:
                time.sleep(self._sleep_interval)
                pass
            else:
                time.sleep(first_delay)
                pass

            # print('Current time : %s' % time.time() )
            if first_delay >= 0 or time.time() > self._last_on_time:
                first_delay = -1
                self._last_on_time = (self._timer_interval + time.time())

                self._loop_count += 1
                if self._target:
                    rc = self._target(*self._args, **self._kwargs)
                    # rc = self.onTime()
                if (rc):
                    self._successive_failure += 1
                    self._sum_failure += 1
                    pass
                else:
                    self._successive_failure = 0
                    pass

                pass
            else:
                continue
            pass
        print('[%s] %s' % (datetime.datetime.now(), self._last_error))
        # self.d[self.name] = {}
        # self.d[self.name]['last_error'] = self.last_error
        self.d[self.name] = self._last_error
        sys.exit(self._exitcode)

    def onTime(self):
        """
        """
        rc = 0
        print('[%s] onTime %d' % (datetime.datetime.now(), self._loop_count))
        # TODO
        return 1


def do_concurrent_test(jobs):
    """
    """

    manager = Manager()
    d = manager.dict()
    rc = 0

    first_exit_job = {}
    for name, job in jobs.items():
        job.d = d
        job.start()
        pass
    while 1:
        any_done = 0
        for name, job in jobs.items():
            if job.is_alive():
                pass
            else:
                first_exit_job['name'] = job.name
                first_exit_job['exitcode'] = job.exitcode
                any_done = 1
                rc = job.exitcode
                break
            time.sleep(1)
            pass
        if any_done: break

    for name, job in jobs.items():
        if job.is_alive():
            job.terminate()
            pass
        pass

    print('first exit job : %s' % str(first_exit_job))
    if rc:
        print('AT_ERROR : %s' % str(d) )
        pass
    return rc, d


def do_GUI_validator_test(jobs):
    """
    """

    rc = 0
    manager = Manager()
    d = manager.dict()

    for name, job in jobs.items():
        job.d = d
        job.start()
        pass

    for name, job in jobs.items():
        job.join()

    for name, job in jobs.items():
        if job.exitcode:
            pass
        else:
            rc = 1
            break
    return rc


global repeat_cnt
repeat_cnt = 0


def func_always_fail():
    """
    """
    global repeat_cnt

    repeat_cnt += 1
    print('[%s] func_always_fail -- %d' % (datetime.datetime.now(), repeat_cnt))
    return 1


def func_always_pass():
    """
    """
    print('[%s] func_always_pass' % (datetime.datetime.now()))
    return 0


if __name__ == '__main__':
    manager = Manager()
    d = manager.dict()

    p = Timed_Job(target=func_always_fail)
    p.name = 'Always Fail'
    p.d = d

    p.setup(interval=30, max_count=8, exit_successive_failure=5)
    p.start()
    # time.sleep(10)
    # p.terminate()
    p2 = Timed_Job(target=func_always_pass)
    p2.name = 'Always Pass'
    p2.setup(interval=20)
    p2.start()

    # p2.join()
    p.join()

    print('== exit code : %s (%s)' % (p.exitcode, (d)))
