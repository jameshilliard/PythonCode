#!/usr/bin/env python
# coding=utf-8

__author__ = 'root'

import MySQLdb

conn = MySQLdb.connect(host='localhost', user='root', passwd='123qaz', db='test', charset='utf8')
cursor = conn.cursor()

try:
    cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
    cursor.execute('insert into user values(%s, %s)', ['1', 'Michael'])
    cursor.rowcount()
    conn.commit()
    cursor.close()

except MySQLdb.Error, e:

    cursor.execute('select * from user where id = %s', '1')
    values = cursor.fetchall()
    print values


finally:
    cursor.close()
    conn.close()