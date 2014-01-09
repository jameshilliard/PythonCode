#coding=utf-8


initial_dir = "/home/elen/Spirent/"
result_file = "/home/elen/Spirent_result.xls"
temp_dir = "/home/elen/Spirent_temp/"

####################remove last result#######################
def remove_tempdir():
    if os.path.isdir(temp_dir) is True:
        os.system('rm -rf %s' % temp_dir)
        print "Temp dir had been removed"
        os.mkdir(temp_dir)
    else:
        print "No such a dir"
        os.mkdir(temp_dir)


remove_tempdir()


def remove_testresult(debug=False):
    if os.path.isfile(result_file) is True:
        os.system('rm -rf %s' % result_file)
        if debug:
            print "Result file had been removed"
    else:
        print "No such a file"


remove_testresult()

all_result = os.listdir(initial_dir)
all_result.sort()

try:
    for i in range(len(all_result)):
        tmp_file = initial_dir + all_result[i]
        list_number_temp = []
        f = open(tmp_file, 'r')
        for eachline in f.readlines():
            Keyword_casename = "^\<cts\:testCase+.*\>\s?$"
            Search_casename = re.search(Keyword_casename, eachline)
            if Search_casename is not None:
                casenum_temp = Search_casename.group().split("\"")[1]
                list_number_temp.append(int(str.strip(casenum_temp)))
            #        print "\'%s\'"%x

        temp_file_path = temp_dir + casenum_temp
        f.close()
        os.system('cp %s %s' % (tmp_file, temp_file_path))

except Exception, e:
    print e
    exit(1)

