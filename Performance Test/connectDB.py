#coding=utf-8
#__author__ = 'royxu'

import MySQLdb

#########################################

# Preparing Global parameters

#########################################

# MySQL login info

mysql_url = '192.168.20.108'

mysql_user = 'root'

mysql_passwd = '123qaz'

mysql_db = 'python'


def  getValue(values, Theoretical_Values, dates):

    con = MySQLdb.Connection(host=mysql_url, user=mysql_user, passwd=mysql_passwd, db=mysql_db);

    with con:
        cur = con.cursor()

        cur.execute("Select * FROM cpu_loading_performance")

        numrows = int(cur.rowcount)

        for i in range (numrows):

            row = cur.fetchone()

            print row[0], row[1], row[2], row[3]

            dates.append(row[1])

            Theoretical_Values.append(row[2])

            values.append(row[3])

    print dates

    print  len(dates)

    print Theoretical_Values

    print  len(Theoretical_Values)

    print values

    print  len(values)

def main():
    # init data
    dates = []
    values = []
    Theoretical_Values = []
    #print "start"
    getValue(values, Theoretical_Values, dates)
    #print dates
    #print type(dates)
    #print len(dates)

if __name__ == '__main__':
    main()