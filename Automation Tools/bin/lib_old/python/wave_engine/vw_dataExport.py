#!/usr/bin/env python
""" Data Exporting Module:

    Detailed Info:
    ###############################################################################
    # Required Modules:
    #                 MySQL-python (version 1.2.2 or later)
    #                 sqlobject    (version 0.10.1 or later (this package is not
    #                               mandatory for this release but may be required
    #                               for future releases of this code)
    #                 elementtree  (version 1.2.6 or later)
    #                 FormEncode   (version 0.2.2 and is required by MySqlPython)
    #
    #
    # Version         :  1.0 version of Data Export Module
    # Developed by    :  TEL Engineers
    #
    # Date of release :  22nd August 2008
    #
    #                    1.) This Module contains the necessary patch for MastertestPlan which 
    #                        will enable the support for MySQL Database.
    #                    2.) vw_dataExport.py file which contains the class definition
    #                        for ExportData module
    #                    3.) basetest.py file with necessary patch for exporting
    #                        result,error,version data to the Database
    #                    4.) vw_auto.tcl with necessary patch to run the test through command line
    #                        with enable/disable database option 
    #
    # Basic requirements:
    #                 1.) install MySQL server on your system
    #                 2.) create a database with a name of your choice(default: veriwave)
    #                 3.) create an user account (default:  username- veriwave Password- veriwave)
    #                 4.) Use the Flag "--db" to enable the support for database to run from vw_auto.tcl.    
    #                     or to run from the wml,or through masterscript.py file.
    # Known bugs        :
    #                    1)This code is tested for the Packet_loss and Throughput test categories, for
    #                      other categories it has to be checked once.
    #                    2)This has been tested only using linux at present,Still has to be tested for windows 
    #                      environment.
    #                    Otherwise we do not find any bugs as of now and any bugs may
    #                    as a part of testing and we request the tester to pass on the bugs info
    #                    to the following mail ids which will enable us to come up with more
    #                    robust code design.
    #
    #                    maheshvshet@tataelxsi.co.in or vinayakumarp@tataelxsi.co.in or tkchaitanya@tataelxsi.co.in
    #
    # How to run        :
    #                    Traverse to the /automation/bin directory of your build then enter the following command
    #                   ./vw_auto.tcl -f <path for the Configuration file> <All the Options You want to enable> --db
    #
    #                   This will automatically add test results into the database to the corresponding tables.
    #                   (The tests have been tried on the Cent-OS (Linux flavour) environment for 
    #                    PLOSS and TPUT tests only)
    #
    # Tables created    :  When a test is run with database support enabled, this module creates tables namely,
    #                     SessionTable (when run from the MasterTestPlan)
    #
    #                     TestCaseTable
    #                     TestContextTable
    #                     TestMappingTable
    #                     TestTypeTable
    #
    #                     TestSpecific Trial Results table with the Test category name:
    #                     unicast_packet_loss_ResultsTable
    #                     unicast_unidirectional_throughput_ResultsTable
    #

"""
try:
    import MySQLdb
    from sqlobject import col
    from sqlobject import *
    import odict  
    #global testname
except ImportError, msg:
    print 'SQLObject package is not installed. URL: http://www.sqlobject.org/'
    raise SystemExit, msg

try:
    from _mysql_exceptions import ProgrammingError, OperationalError
except ImportError, msg:
    print 'mysqldb package is not installed: URL: http://sourceforge.net/projects/mysql-python'
    raise SystemExit, msg

""" database_tables is a list containing standard tables that are created as per specification"""
database_tables = [
                    'SessionTable',
                    'TestCaseTable',
                    'TestContextTable',
                    'TestTypeTable',
                    'TestMappingTable'
                  ]

## User can select the test context parameters for logging into database.
## Only constraint is whenever any changes to the parameters logging into database,
##  The table need to recreated.
parameter_default_list= [
                              "TestCaseID",
                              "Band",
                              "Channel",
                              "ILoadList",
                              "FrameSizeList",
                              "Method", 
                              "Ssid",
                              "TxPower"
                                ] 
table_info = {
             "SessionTable":[
                              "SessionID", "integer_primary",
                              "SessionName", ["string", 100],
                              "StartTime","datetime",
                              "EndTime","datetime",
                              "Description",["string", 200]
                            ],
             "TestCaseTable":[
                              "TestCaseID", "integer_primary",
                              "TestCaseName", ["string", 100],
                              "StartTime", "datetime",
                              "EndTime","datetime",
                              "Outcome", ["string", 15],
                              "Description",["string", 255],
                              "LoggingDirectory",["string",255]
                             ],
             "TestContextTable":parameter_default_list,
             "TestTypeTable":[
                              "TestTypeID", "integer_primary",
                              "TestName", ["string", 50],
                              "TestDescription",["string", 255]
                             ],
             "TestMappingTable":[
                               "TestCaseID", "integer",
                               "TestTypeID", "integer"
                                ]
             }


class ExportData (object):
    """
       Main class for exporting the table results to Mysql database
       Support could be extended to other database's as well

##################################################################################################
# Class ExportData:
#
# Function        : On creating an object of this class connects to the configured database and
#                   returns the connection handle. The initialisation will capture the database
#                   connection parameters from the database dictionary. 
#
# Methods available:
#     1. connectToDatabase      args: None (helps connecting to database explicitly is not done at init level)
#     2. disconnectDatabase     args: None (Disconnects from the database and should be used at the end of the test)
#     3. createTable            args: table name to be created,dictionary containing the coulmn name as key 
#                                     and corresponding datatype as the value (creates tables on demand) 
#     4. updateTable            args: tablename, colname, value
#     5. insertIntoTable        args: tablename, dictionary containing the coulmn name as key and corresponding data as the
#                                     value 
#     6. readEntireTable        args: tablename
#     7. readTable              args: tablename, colname, data
#     8. readTableLastrow       args: tablename, colname, data = 1
#     9. checkTableExistance    args: tablename
#    10. createTrialtable       args: testname, colnames, colvalues
#    11. sendTrialResults       args: testname, dictionaries required for creating TestcaseTable,TestContextTable,
#                                     unicast_packet_loss_ResultsTable
#    12. createTypeandMappingTables args:None (creates TestTypeTable,TestMappingTable) 
#    13. createTable_list       args: tablename,list of tuples containing column names and datatypes
#                                      In this proc we create table by parsing the List of Tuples
#    14.insertIntoTable_list    args:tablename,list of tuples containing column names and values
#                                      In this proc we create table by parsing the List of Tuples
#    15.readColumnNames         args: tablename (Read all the column names of the given table)
#    16.alterTable_list         args: tablename, col_type_list(list of tuples with new column names to be added, as first
#                                     entry of tuple and datatype as second entry of tuple.)
#
##############################################################################################################
    """
 
    def __init__(self,server_name,database_type,database_name,login_name,login_password):
        """
          This is just an initalisation process"
        """         
        self.server_name    = server_name 
        self.login_name     = login_name
        self.database_name  = database_name
        self.database_type  = database_type
        self.login_password = login_password
        print self.server_name,self.login_name,self.database_name,self.database_type,self.login_password
  
    def readdatabases(self):

      statement ='show databases;' 
      self.cursor.execute(statement)
      rows=self.cursor.fetchall()
      database_list=[]
      for each in rows: 
         database_list=database_list+[each[0]]        
      return database_list
 
    def createdatabase(self):
       
      db=MySQLdb.connect(user=self.login_name, passwd=self.login_password, host=self.server_name) 
      self.handler = db
      self.cursor  = db.cursor()
      statement='create database %s' %self.database_name
      databases=ExportData.readdatabases(self) 
      if not self.database_name in databases:
         self.cursor.execute(statement) 
         self.handler.commit()  
    def connectToDatabase(self):
        """
          Procedure to connenct to  the MySQL Database as given in the database dictionary, using the 
          MySQLdb.connect method.  then Initialize the handler and cursor for that database.
        """
        db=MySQLdb.connect(user=self.login_name, passwd=self.login_password, host=self.server_name, db=self.database_name)
        self.handler = db
        self.cursor  = db.cursor()

    def disconnectDatabase(self):
        """
          Disconnect from the database after all the operations on the database is over.
        """
        self.cursor.close()
        self.handler.close()

    def checkTableexistence(self,tablename):
        """
            Check the existence of the table specified by the tablename and return 1 if exists and 0 if it does not.
        """

        statement = "show tables"
        self.cursor.execute(statement)
        rows = self.cursor.fetchall()

        for i in range(len(rows)):
            if tablename in rows[i]:
                return 1
        return 0

    def createTable(self, tablename,col_type_dict,Extra=''):
         """
           This will create the table with the given column names and datatypes,
           in this proc we are using dictionaries, for getting the input
         """   
         if not ExportData.checkTableexistence(self,tablename):
                statement = ' create table %s (' %tablename
                
                colname=col_type_dict.keys()
                coltype=col_type_dict.values()
                for (col_names,col_type) in map(None,colname,coltype):
                    statement = statement+ '%s %s not null,' %(col_names,col_type)
                statement1=statement.rstrip(',')
                statement1=statement1 + ')'
                if Extra != '':
                   statement1 =statement1+ '(%s)'%Extra
                statement1=statement1 +';'  
                self.cursor.execute(statement1)
                self.handler.commit()
         else:
           print "ERROR: TABLE ALREADY EXISTS"               
         


    def readEntireTable(self, tablename):
         statement = "select * from %s;" % (tablename)
         self.cursor.execute(statement)
         self.handler.commit()
         rows = self.cursor.fetchall()
         return rows

    def readTable(self, tablename, colname, data):
         statement = "select * from %s where %s=%s" % (tablename, colname, data)
         self.cursor.execute(statement)
         self.handler.commit()
         rows = self.cursor.fetchall()
         return rows
    
    def readColumnNames (self, tablename):
          statement = 'desc %s;' % (tablename)
          self.cursor.execute(statement)
          rows = self.cursor.fetchall()  
          return rows

    def readTableLastrow(self, tablename, colname):
         statement = 'select * from %s order by %s;' % (tablename, colname)
         self.cursor.execute(statement)
         rows = self.cursor.fetchall()
         return rows[-1]


    def readTablecolumns(self, tablename):
         statement = 'show columns from '+str(tablename)+";"
         self.cursor.execute(statement)
         rows = self.cursor.fetchall()
         return rows

    def Convert_mysql (self,list_elements,key='list'):
       if key == 'list':
         new_list=[]
         for value in list_elements:
              if value=='Average Jitter(us)':
                 value ='AverageJitter'
              value=''.join(value.split())
              value=''.join(value.split("/"))
              value=''.join(value.split(":"))
              value=''.join(value.split("%"))
              value=''.join(value.split("-"))
              value=''.join(value.split("."))
              value=''.join(value.split("(")[0])  
              new_list=new_list+[value]

       else:
          new_list=[]
          for each_tuple in list_elements:
              value =each_tuple[0] 
              if value=='Average Jitter(us)':
                 value ='AverageJitter'
              value=''.join(value.split())
              value=''.join(value.split("/"))
              value=''.join(value.split(":"))
              value=''.join(value.split("%"))
              value=''.join(value.split("-"))
              value=''.join(value.split("."))
              value=''.join(value.split("(")[0])
              new_list=new_list+[(value,each_tuple[1])]   
       return new_list
 
    def createAllTable(self):
        """
            Create All the tables specified by the database_tables and get the corresponding col_name
            and column type from table_info dictionary.
        """
        for table in database_tables:
            table_list = table_info[table]
            statement = 'create table %s (' % (table)
            index = 0
            statement1=''
            if table=="TestContextTable":
               sub ='' 
               for tempor in table_list:
                   sub=sub+tempor+' '+'VARCHAR(50)'+','
               statement =statement+sub 
               statement1=statement.rstrip(',')  
               statement=statement1
            else: 
             while(1):
                if index >= len(table_list):
                    break
                colname = table_list[index]
                coltype = table_list[index + 1]

                if coltype == 'integer_primary':
                    sub = colname + ' INT PRIMARY KEY AUTO_INCREMENT'
                elif len(coltype) == 2:
                    if coltype[0] == "string":
                        length = coltype[1]
                        sub = colname + ' VARCHAR('+ str(length) + ')'
                elif coltype == "datetime":
                    sub = colname + ' datetime'
                elif coltype == "float":
                    sub = colname + ' float'
                elif coltype == "integer":
                    sub = colname + ' int'

                if index < len(table_list) and index != 0:
                    statement = statement+","

                index = index + 2
                statement = statement+sub
                del(sub)

            statement = statement+");"
            try:
                self.cursor.execute(statement)
            except:
                pass
        else:
           return 0
                        
    def createTable_list(self, tablename,col_type_list,Extra=''):
       """
        Basically used for creating the Test specific Results Table,using List of tuples 
       """
    
       if not ExportData.checkTableexistence(self,tablename):
          statement =' create table %s (' %tablename
          for each_tuple in col_type_list:
              if each_tuple[0]=='AverageJitter(us)':
                 col_change='AverageJitter'
                 each_tuple=(col_change,each_tuple[1]) 
              statement = statement+ '%s %s ,' %(each_tuple[0],each_tuple[1])  
          statement1=statement.rstrip(',')
          statement1=statement1 + ')'
          if Extra != '':
                statement1 =statement1+ '(%s)'%Extra
                statement1=statement1 +';'
          self.cursor.execute(statement1)
          self.handler.commit()
       else:
          print "ERROR: TABLE ALREADY EXISTS"
       

    def alterTable_list(self, tablename,col_type_list):
         """
           Used for altering the table like adding new columns,
           changing permissions etc....
         """
         if ExportData.checkTableexistence(self,tablename):  
            col_names_table=ExportData.readColumnNames(self,tablename)
            ## Added a check for Duplicate column names, as we use
            ## alter table for both PF and ERROR criteria 
            for each_tu in col_names_table:
                each_col_list=[]
                each_col_list=each_col_list+ [each_tu[0]]
            for each_tuple in col_type_list:
                  statement='alter table %s add %s %s ' %(tablename,each_tuple[0],each_tuple[1])
                  try:
                     each_col_list.index(each_tuple[0])
                  except:  
                     self.cursor.execute(statement)
                     self.handler.commit()
         else:
             print "Table do not exist, use create table and create it first"
 
    
    def insertIntoTable_list (self,tablename,Results_list):
      """  
        This will populate the Test specific results table, using List of tuples
      """
      #print "The results list is %s" %Results_list
      if tablename == "TestContextTable":
         statement = 'insert into %s (' %tablename
         for each_tuppal in Results_list:
                statement=statement+'%s,'%each_tuppal[0]
         statement1=statement.rstrip(',')
         statement1=statement1 + ')'
         statement1=statement1+' values ( '
         for each_tuppal in Results_list:
               statement1=statement1+'"%s",'%each_tuppal[1]
         statement2=statement1.rstrip(',')
         statement2=statement2+');'
         self.cursor.execute(statement2)
         self.handler.commit()
 


      else: 
       if len(Results_list)== 8:
        statement = 'insert into %s (' %tablename
        for each_tup in Results_list[0:8]:
             statement=statement+'%s,'%each_tup[0]
        statement1=statement.rstrip(',')
        statement1=statement1 + ')'
        statement1=statement1+' values ( '
        for each_tup in Results_list[0:8]:
               statement1=statement1+'"%s",'%each_tup[1]
        statement2=statement1.rstrip(',')
        statement2=statement2+');'
        try:
            self.cursor.execute(statement2)
            self.handler.commit()
        except:
            print "\nThe Error Occured is Not Compatible with MySQL Syntax , hence Unable to Log it into the DataBase\n" 
 
       else:
         for each_tuple in Results_list[9:] :
            statement = 'insert into %s (' %tablename
            for each_tup in Results_list[0:8]:
                statement=statement+'%s,'%each_tup[0]
            header= Results_list[8]
            test=''
            if test=='latency':
               header= header[0:8] 
            mod_header=ExportData.Convert_mysql (self,header)
            for value in mod_header:
              statement=statement+'%s,' %value
            statement1=statement.rstrip(',')
            statement1=statement1 + ')'
            header=str(header)  
            statement1=statement1+' values ( '
            for each_tup in Results_list[0:8]:
               statement1=statement1+'"%s",'%each_tup[1]
            for val in each_tuple:
                 statement1=statement1+'"%s",'%val
            statement2=statement1.rstrip(',')
            statement2=statement2+');'
            self.cursor.execute(statement2)
            self.handler.commit()

            
          
           
    def insertIntoTable (self,tablename,dict_db,Extra='' ):
             """
                This function will insert values into an existing table,
                based on the user input
             """
             if tablename== 'TestTypeTable':
                 statement = 'insert ignore into %s ( ' %tablename
             else: 
                 statement = 'insert into %s ( ' %tablename
             for col_names in dict_db.keys():
                  ##### Removes all unnecessary thing for MySQL
                  col_names=''.join(col_names.split())
                  col_names=''.join(col_names.split("/"))
                  col_names=''.join(col_names.split(":"))
                  statement =statement+ '%s,' %col_names
             statement1=statement.rstrip(',')
             statement1 =statement1 + ') values ('  
             for col_values in dict_db.values():
                 statement1 =statement1 + '"%s",' %col_values
             statement2=statement1.rstrip(',')
             statement2 =statement2+ ');'
             self.cursor.execute(statement2)
             self.handler.commit()


    def updateTable (self,tablename,dict_db,ref_dict_db):
          statement = 'update low_priority %s set %s =%s where %s =%s' %(tablename,dict_db.keys(),dict_db.values(),ref_dict_db.keys(),ref_dict_db.values())
          self.cursor.execute(statement)


    def sendTrialResults(self,testname,TC_dict_db,TrialconfigTable_list_db,TestContextTable_list_db,Results_list_db):
         """
            This procedure will get all the List of Tuples through the funtion call from basetest.py module.
            It will create the necessary tables as per the dictionaries and will populate 
            the table with the values obtained from basetest.py module. 
               The entire logic used is based on parsing the List of Tuples and calling create and insert
            into table procedures defined above.
         """ 
         ExportData.createdatabase(self)  
         ExportData.connectToDatabase(self)
         ExportData.createAllTable(self)  
         global Testname
         Testname=testname
         #ExportData.createTypeandMappingTables(self)
         ### No need to check for table existence we 
         ### are using try and except before creating table....
         Extra_ins=''  
         #Call the procedure to create the TestType and TestMapping Table
         for dict in (TC_dict_db,TestContextTable_list_db,Results_list_db) :
             if dict == TC_dict_db:
                tablename='TestCaseTable'
                ExportData.insertIntoTable(self,tablename,dict)
                ExportData.createTypeandMappingTables(self) 
             if dict==Results_list_db or TestContextTable_list_db:
                ###creating the Test specifc Results table (here we are populating
                ###Results_list and version_dict dictionary into the test specific
                ###TrialResults table 
                if dict == TestContextTable_list_db:
                   dataTestCaseID = ExportData.readTableLastrow(self, "TestCaseTable","TestCaseID")[0]
                   tablename= 'TestContextTable'
                   list_insert=[]
                   list_insert=list_insert+[('TestCaseId',dataTestCaseID)]
                   col_names_table=ExportData.readColumnNames(self,tablename)
                   for each_tup in col_names_table:
                       col_name_list=[] 
                       col_name_list=col_name_list+ [each_tup[0]]

                   for colname in TestContextTable_list_db:
                      if colname[0] in  table_info[tablename]:
                          if colname in list_insert:
                             pass
                          else:
                            list_insert=list_insert+[colname]
                   ExportData.insertIntoTable_list(self,tablename,list_insert)
                   #ExportData.alterTable_list(self,tablename,list_append_table)

                if dict==Results_list_db:
                   tablename= testname+ '_resultstable'
                    
                   ### Creating the list of Tuples used to create table
                   col_type_list= [('TrialResultsID','int primary key auto_increment') ]
                   col_type_list=col_type_list+ [('TestCaseId','int ')]
                   for colname in TrialconfigTable_list_db:
                     if colname[0] == 'TestStatus':
                       col_type_list=col_type_list+[(colname[0],'int')]
                     elif colname[0] == 'ErrorCondition':
                         col_type_list=col_type_list+[(colname[0],'varchar(255)')]
                     else:
                       col_type_list=col_type_list+[(colname[0], 'varchar(100)')]
  
                   ### Adding Test Case ID to Results list of Tuples                 
                   Results_list=[] 
                   dataTestCaseID = ExportData.readTableLastrow(self, "TestCaseTable","TestCaseID")[0]
                   Results_list=Results_list+[('TestCaseId', dataTestCaseID)]
                   ### Merging Version,Error tuples to Results list of Tuples
                   if TrialconfigTable_list_db[0][1]==0: 
                      if  testname == 'unicast_latency':
                            header=Results_list_db[0][0:8]
                      elif testname == 'qos_service':
                           flag_header_ctl=1
                           Results_mod_list=[]
                           for each_tu in Results_list_db:
                               if len(each_tu)==1:
                                  trial_tu= tuple (each_tu[0].split('-')) 
                                  te=Results_list_db.index(each_tu) 
                                  if flag_header_ctl ==1:                                  
                                     Results_mod_list=Results_mod_list+[((trial_tu[0],)+Results_list_db[te+1])]
                                     flag_header_ctl=0
                                  Results_mod_list=Results_mod_list+[((trial_tu[1],)+Results_list_db[te+2])]
                               else:
                                  pass   
                           Results_list_db=Results_mod_list 
                           header=Results_mod_list[0]
                      elif (testname == 'roaming_delay') or (testname == 'roaming_benchmark'): 
                            for each_tup in  Results_list_db:
                                     tmp=Results_list_db.index(each_tup)
                                     if each_tup[0].startswith('Start'):
                                          Results_list_db[tmp]=('Client_ID',)+each_tup[1:]
                                     elif len(each_tup) ==1:
                                         Results_list_db[tmp]=tuple(each_tup[0].split(','))
                            header=Results_list_db[0]
                      else: 
                            header=Results_list_db[0]  
                        
                      ##### When first table is created with PF disabled, next time if the user enabled PF 
                      ####  we will have to add extra columns to the existing table, this code will take care of that 
                      if ExportData.checkTableexistence(self,tablename):
                         col_names_table=ExportData.readColumnNames(self,tablename)
                         flag_control =1
                         flag_control_err=0
                         if len(col_names_table) == 9:
                             flag_control_err=flag_control_err+1 
                         for each_tuple in col_names_table:
                              each_col=each_tuple[0] 
                              if each_col.startswith ("USC"):
                                 flag_control=0
                               
                         extra_col_type_list=[] 
                         if flag_control == 1: 
                            for each_col_list in header: 
                                if each_col_list.startswith ("USC"):
                                   extra_col_type_list=extra_col_type_list+[(each_col_list,'varchar(10)')]
                                else:
                                    pass 
                            if len(extra_col_type_list ) != 0:
                                      key='tuple'
                                      mod_list= ExportData.Convert_mysql (self,extra_col_type_list,key)
                                      for each_extra in mod_list :
                                        colname=each_extra[0]
                                        tmp = mod_list.index(each_extra) 
                                        extra_col_type_list[tmp]=(colname,each_extra[1]) 
                                      ExportData.alterTable_list(self,tablename,extra_col_type_list)                 
                         ### This if loop will take care of a test case, where at first run itself
                         ### test fails, so table does not have any results it has only error info
                         ### hence if in the next run test passes, we are adding that extra results
                         ### columns to the already exiatingtable.
                         if flag_control_err== 1:
                                 extra_col_type_list_err=[]
                                 if len(header)== 0:
                                       pass
                                 else:       
                                       mod_header=ExportData.Convert_mysql(self,header) 
                                       for colname in mod_header:
                                              extra_col_type_list_err=extra_col_type_list_err+[(colname,'varchar(10)')]
                                       ExportData.alterTable_list(self,tablename,extra_col_type_list_err)  
                      mod_header=ExportData.Convert_mysql (self,header)
                      for colname in mod_header:
                        col_type_list=col_type_list+[(colname,'varchar(100)')]
                   Results_list=Results_list+TrialconfigTable_list_db
                   ### Checking for Latency, to remove the buckets from results  
                   if  testname == 'unicast_latency':
                       Results_db=[]
                       for each_tup in Results_list_db:
                           tmp=Results_list_db.index(each_tup)
                           if each_tup[0:8]==header and tmp != 0:
                              pass
                           elif each_tup[0:8] == ('',):
                              pass
                           else: 
                              Results_db=Results_db+[each_tup[0:8]]
                       Results_list_db=Results_db 
                   ### Checking for MFR, to find Maximum forwarding rate.... 
                   if  testname == 'unicast_max_forwarding_rate':
                       Results_db=[]
                       ## Not required now as we are using an different logic for this test 
                       #for each_tup in  Results_list_db:
                       #     if each_tup != header:
                       #            Results_db=Results_db+[each_tup[7]] 
                       #Results_db.sort()
                       #for each_tup in Results_list_db:
                       #    try:
                       #      tmp= each_tup.index(Results_db[-1])              
                       #      Results_list_db=[each_tup] 
                       #    except:
                       #       pass   
                               
                   Results_list=Results_list+Results_list_db
                   if not ExportData.checkTableexistence(self,tablename):
                       ExportData.createTable_list(self,tablename,col_type_list)
                   ExportData.insertIntoTable_list(self,tablename,Results_list)
                        
         ExportData.disconnectDatabase(self)
    def  createTypeandMappingTables(self):
         """
          This procedure will create the TestTypeTable and TestMappingTable in 
          the database and populate them,  it does not require any input from the user
         """           
         ExportData.connectToDatabase(self)
         col_type_dict= {}

         tablename= 'TestTypeTable' 
         global Testname
         TestTypeTable_dict={}
         testname_list=['unicast_packet_loss','unicast_max_forwarding_rate','unicast_latency','unicast_max_client_capacity','unicast_unidirectional_throughput','rate_vs_range','roaming_delay','roaming_benchmark','qos_service','qos_capacity','voip_roam_quality','tcp_goodput','aaa_auth_rate'] 
         testid_list=[1,2,3,4,5,6,7,8,9,10,11,12,13]
         testdesc_list=[
" The packet loss test measures the rate at which frames are dropped, as well as the rate at which they are forwarded, by the system under test (SUT) when presented with specific traffic loads and frame sizes.",

" The maximum forwarding rate test measures the highest rate at which the system under test (SUT) can transfer frames between its ports, regardless of loss; it measures the ultimate traffic handling capacity of the SUT. This test measures the maximum forwarding rate according to RFC 2285.",

" The latency test measures the delay incurred by frames passing through the system under test (SUT). Italso measures the amount of jitter, which is the variation in latency over many frames. Latency and jitter are key performance metrics that determine how well the SUT can handle traffic, such as voice or real-time video, that is sensitive to the delay between source and destination. This test measures latency and jitter according to RFC 2544 and RFC 3550, respectively." ,

" The Maximum Client Capacity test measures the number of clients that can successfully associate with APs in the SUT and transfer traffic to the distribution system (wired AN). It measures the ability of APs in the SUT to support a large number of simultaneously connected users.",

" The Throughput Benchmarking test identifies the maximum rate at which the system under test (SUT) can forward packets without loss.This test determines the throughput rate by using a binary search algorithm. The test starts by offering a predetermined starting load to the SUT. Packet loss is then measured. If packet loss is detected the offered load (OLOAD) is cut in half. If there is no packet loss the OLOAD is doubled. This process continues until the difference between OLOAD values is less than the search resolution setting. The process is repeated for each frame size specified in the test.",

" The rate vs. range test measures the variation in forwarding rate of the system under test (SUT), at a fixed intended load, as the test client(s) are moved away from the SUT. The test clients are generated by the WaveTest system, and the distance between each test client and the SUT is simulated by changing the power and effective frame error ratio (FER) presented by the client to the SUT.The test can be run using different intended loads and different frame sizes in order to understand how the SUT will respond to different types of traffic in a real environment with mobile clients.",

" The roaming delay test measures the roaming delays and packet loss of the clients roaming when the SUT is stressed with a specified roam pattern and each client configured with certian dwell time(s). Client roam pattern can be tuned with the option of clients starting points distributed among the APs.",

"The Roaming Benchmark test determines the number of roams per unit of time that the WLAN controller can support. The test reports the roam delay, failed roams and packet loss for a particular roam rate for the specified configuration.Unique roaming patterns can be specified for each network (SSID). Within the network, the client groups follow a predefined roaming pattern.",

" The test determines the maximum amount of low priority traffic that the System Under Test (SUT)can sustain without breaking the Service Level Agreement (SLA) for a specified number of VoIP calls. The Service Level Agreement can be specified as a minimum R-value or a combination of maximum Packet Loss, Latency and Jitter of the VoIP calls.",

 " The VoIP QoS Service Capacity test determines the maximum number of VoIP calls the System Under Test (SUT) can maintain at a specified Service Level Agreement (SLA) in the presence of best effort traffic load. The SLA can be specified as an R-value or as a combination of maximum latency, packet loss and jitter",

 "The Roaming Service Quality test determines the effect of roaming on call quality as measured by the R-value and dropped calls. The test measures the anticipated drop in call quality when wireless clients begin to roam from one AP to another.",

"The TCP Goodput test measures the number of TCP payload bytes per second that the system under test (SUT) can transfer between its ports and the maximum segment size (MSS).",

"The AAA Authentication Rate test measures the performance of AAA servers.  The test generates a large number and variety of client connections using 802.1x authentication transactions at very high rates to the authentication server, enabling you to determine the actual authentication rate supported by the system under test (SUT). You can also use this test to perform scaled authentication load testing, regression testing and performance-envelope testing."]

         temp_var=testname_list.index(Testname)
         TestTypeTable_dict['TestTypeId']=testid_list[temp_var]
         TestTypeTable_dict['TestName']= Testname 
         TestTypeTable_dict['TestDescription']=testdesc_list[temp_var]
         ExportData.insertIntoTable(self,tablename,TestTypeTable_dict)

         tablename= "TestMappingTable"
         TestMappingDict={} 
         dataTestCaseID = ExportData.readTableLastrow(self, "TestCaseTable","TestCaseID")[0]
         #dataTestTypeID = ExportData.readTableLastrow(self, "TestTypeTable","TestTypeID")[0]
         
         TestMappingDict['TestCaseID']=dataTestCaseID
         TestMappingDict['TestTypeId']=testid_list[temp_var]
         ExportData.insertIntoTable(self,tablename ,TestMappingDict )

if  __name__ == '__main__':
      import sys
      if sys.argv[1:]:
        if sys.argv[1] in ['-h', '--help']:
            print __doc__
            sys.exit(0)
        elif sys.argv[1] in ['-t', '--test']:
            import doctable
            doctable.tablemod(verbose=True)
        else:
            print 'Please try -h option for more help and -t option to run doctable'
      else:
        print 'Please try running $ python %s -h for help' % sys.argv[0]
       
            
  
