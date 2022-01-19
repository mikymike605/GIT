--USE CMD PROMPT
rman target sys/rcat@ngwd
Recovery Manager: Release 11.2.0.3.0 - Production on Thu Sep 10 11:52:36 2020
Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
connected to target database: NGWD (DBID=1289902287)


--USE RMAN PROMPT
CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO 'G:\Oracle\export\ngwd\%F';
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT   'G:\Oracle\export\ngwd\df0_%d_%s_%t';
CONFIGURE SNAPSHOT CONTROLFILE NAME TO 'G:\Oracle\export\ngwd\SNAP_CTL_XE.ORA';

restore database from TAG='TAG20200910T141825'
list backup TAG;

DELETE OBSOLETE;

Run {
list backup ;
DELETE OBSOLETE;
shutdown immediate ;
startup mount ;
backup full database;
backup database plus archivelog;
alter database open ;
}

shutdown immediate
startup nomount
restore database ;
backup database plus archivelog;
alter database mount;


restore database ;

EXIT


--Connect database as sys user to configure it in archivelog mode.
--https://dbatricksworld.com/how-to-configure-oracle-11g-database-in-archivelog-mode/

--USE CMD PROMPT
sqlplus / as sysdba
Verify your database is in archivelog log mode or not, In our case obviously not.

SQL> select log_mode from v$database;
LOG_MODE
------------
NOARCHIVELOG
OR

SQL> archive log list;
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            /u01/app/oracle/product/11.2.0/dbhome_1/dbs/arch
Oldest online log sequence     1
Current log sequence           3
To configure database in archivelog mode, follow the steps below:

Step-I: Shutdown database:

SQL> shutdown immediate;
Step-II: Startup your database in mount mode:

SQL> startup mount;
Step-III: Configure database in archivelog:

SQL> alter database archivelog;
Step-IV: Open database in read write mode:

SQL> alter database open;
Database is in archive log mode now, you can verify with following SQL command, Result shows Database log mode is “Archive Mode” and “Automatic archival” is Enabled.

SQL> archive log list;
Database log mode               Archive Mode
Automatic archival              Enabled
Archive destination             /u01/app/oracle/product/11.2.0/dbhome_1/dbs/arch
Oldest online log sequence      1
Next log sequence to archive    3
Current log sequence            3
You can change archive log destination with following:

SQL> alter system set log_archive_dest_1='LOCATION=/home/oracle/archdir' scope=both;
Following command shows, the database is in archivelog mode:

SQL> select log_mode from v$database;
LOG_MODE
------------
ARCHIVELOG


RUN{
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\C-1289902287-20200909-04' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\DF0_NGWD_10_1050678636' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\C-1289902287-20200909-05' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\DF0_NGWD_13_1050681799' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\C-1289902287-20200909-06' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\DF0_NGWD_15_1050682105' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\DF0_NGWD_16_1050682121' ;
crosscheck backuppiece 'G:\ORACLE\EXPORT\NGWD\DF0_NGWD_17_1050682166' ;
}
