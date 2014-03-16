#coding=utf-8
#__author__ = 'roy xu'
import matplotlib.pyplot as plt
import MySQLdb

#########################################

# Preparing Global parameters

#########################################

# MySQL login info

mysql_url = '192.168.20.108'

mysql_user = 'root'

mysql_passwd = '123qaz'

mysql_db = 'python'


def getValue(idex, values, Theoretical_Values, dates):
    con = MySQLdb.Connection(host=mysql_url, user=mysql_user, passwd=mysql_passwd, db=mysql_db)

    with con:
        cur = con.cursor()

        cur.execute("Select * FROM cpu_loading_cpuload_sky")

        numrows = int(cur.rowcount)

        for i in range(numrows):
            row = cur.fetchone()

            print row[0], row[1], row[2], row[3]

            idex.append(row[0])

            dates.append(row[1])

            Theoretical_Values.append(row[2])

            #values.append(row[3])
            values.append(100 - float(row[3]))

    print idex

    print dates

    print Theoretical_Values

    print len(Theoretical_Values)

    print values


def drawPicture(idex, Theoretical_Values, values):  # draw a Picture from by the data from the Excel
    #fig = plt.figure(figsize=(9.5, 3.5))
    plt.subplots_adjust(bottom=0.4)
    plt.xticks(rotation=90)
    plt.legend(loc="upper right")
    plt.title("CPU Usage")
    plt.xlabel("Idex")
    plt.ylabel("CPU Usage")
    plt.ylim(0, 120)
    plt.plot(idex, values, '-', label='values', color='red', markersize=2)
    plt.plot(idex, Theoretical_Values, 'c', label='Theoretical_Values')
    plt.legend()# show lengend
    plt.show()
    plt.grid(True)  # show grid


def main():
    # init data
    idex = []
    dates = []
    values = []
    Theoretical_Values = []
    getValue(idex, values, Theoretical_Values, dates)
    drawPicture(idex, Theoretical_Values, values)


if __name__ == '__main__':
    main()


