/****************************************************
Filename:  configdb.sql
Description:  configure database for ATLAS 
Author: Jing Ma  2010-03-25
****************************************************/

##create a new database-------------------------------
DROP DATABASE IF EXISTS ATLAS;
CREATE DATABASE ATLAS;
USE ATLAS;

##create tables---------------------------------------
DROP TABLES IF EXISTS job;
CREATE TABLE job ( 
	JobID				varchar(18)			NOT NULL,
	TbedID			Varchar(50)			NOT NULL,
	ProductID		Varchar(50)			NOT NULL,
	FWVersion		Varchar(50)			NOT NULL,
	Image				Varchar(200)		NOT NULL,
	Tsuite			Varchar(50)			NOT NULL,
	Status			int(2)					NOT NULL,
	SubTime			timestamp				NOT NULL,
	StartTime		timestamp				NULL,
	EndTime			timestamp				NULL,
	UserID			Varchar(50)			NOT NULL,

  PRIMARY KEY  (JobID)
);

DROP TABLES IF EXISTS product;
CREATE TABLE product ( 
	ProductID			Varchar(50)			NOT NULL,
	NameforTest		Varchar(50)			NOT NULL,
	NameforPub		Varchar(50)			NULL,
	Customer			Varchar(50)			NULL,
	Manufacturer	Varchar(50)			NULL,
	Description		Varchar(200)		NULL,
	
  PRIMARY KEY  (ProductID)
);

DROP TABLES IF EXISTS firmware;
CREATE TABLE firmware ( 
	FWVersion			Varchar(50)			NOT NULL,
	ProductID			Varchar(50)			NOT NULL,
	Image					Varchar(50)			NOT NULL,
	Description		Varchar(200)		NULL,
	
  PRIMARY KEY  (FWVersion)
);

DROP TABLES IF EXISTS testsuite;
CREATE TABLE testsuite ( 
	Tsuite				Varchar(50)			NOT NULL,
	ProductID			Varchar(50)			NOT NULL,
	FWVersion			Varchar(50)			NOT NULL,
	Description		Varchar(200)		NULL,
	
  PRIMARY KEY  (Tsuite,ProductID,FWVersion)
);

DROP TABLES IF EXISTS testcase;
CREATE TABLE testcase ( 
	TcaseID				Varchar(50)			NOT NULL,
	SuiteID			Varchar(100)			NOT NULL,
	TcaseName			Varchar(50)			NULL,
	Description		Varchar(200)		NULL,
	Content				Text						NULL,
	
  PRIMARY KEY  (TcaseID,SuiteID)
);

DROP TABLES IF EXISTS testresult;
CREATE TABLE testresult ( 
	JobID				  Varchar(18)			NOT NULL,
	TcaseID				Varchar(50)			NOT NULL,
	Result				int(2)					NOT NULL,
	BugID					Varchar(50)			NULL,
	Log						Varchar(400)		NULL,
	Duration			int							NULL,
	StartTime			timestamp				NULL,
	Comments			Varchar(200)		NULL,
	
  PRIMARY KEY  (JobID,TcaseID)
);

DROP TABLES IF EXISTS testbed;
CREATE TABLE testbed ( 
	TbedID				Varchar(50)			NOT NULL,
	ProductID			Varchar(50)			NOT NULL,
	Name					Varchar(50)			NULL,
	PCNum					int(2)					NULL,
	MgmIP					Varchar(50)			NOT NULL,
	OS						Varchar(50)			NULL,
	Comments			Varchar(200)		NULL,
	
  PRIMARY KEY  (TbedID,ProductID)
);

DROP TABLES IF EXISTS users;
CREATE TABLE users (
	UserID				Varchar(16)		NOT NULL,
	PassWord 			Varchar(16) 	NOT NULL,
	Email 				Varchar(50)		NOT NULL, 
	GroupID 			Varchar(16) 	NOT NULL,
	Description		Varchar(200)		NULL,

	PRIMARY KEY(UserID,GroupID)
);

DROP TABLES IF EXISTS groups;
CREATE TABLE groups (
	GroupID				Varchar(16)		NOT NULL,
	GroupName 		Varchar(16) 	NOT NULL,
	Permission		int(2)				NOT NULL,

	PRIMARY KEY(GroupID)
);

##create and grant a new user-------------------------
USE mysql;
DELETE FROM user WHERE User='actiontec';
GRANT ALL ON ATLAS.* TO actiontec@'%' IDENTIFIED BY 'actiontec';
GRANT ALL ON ATLAS.* TO actiontec@'localhost' IDENTIFIED BY 'actiontec';
flush privileges;

# create admin user for atlas;
use ATLAS;
insert into users values("admin","admin","admin@actiontec.com","admin","administrator");