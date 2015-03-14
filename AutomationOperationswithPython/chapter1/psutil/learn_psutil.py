#!/usr/bin/env PYTHON
#coding=utf-8

import psutil
import time
from datetime import datetime

#get mem info
mem = psutil.virtual_memory()
print mem
print mem.total
print mem.used
print mem.free

#get swap info

print psutil.swap_memory()

#get CPU info
print psutil.cpu_times()
print psutil.cpu_times().user
print psutil.cpu_times().nice
print psutil.cpu_count(logical=True)
print psutil.cpu_count(logical=False)

#get disk info
print psutil.disk_partitions(all)
print psutil.disk_io_counters(perdisk=True)

#get net info
print psutil.net_io_counters()

#get other info
print psutil.users()
print psutil.boot_time()
print datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")

# get PID
print  psutil.pids()
p = psutil.Process(2572)

print p.name() 
print p.exe()
print p.status()
print p.create_time()
print datetime.fromtimestamp(p.create_time()).strftime("%Y-%m-%d-%H:%M:%S")
print p.memory_percent()
print p.memory_info()
print p.connections()