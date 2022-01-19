run
{
set until sequence =5;
duplicate target database for standby dorecover nofilenamecheck;
}


create pfile from spfile;
shutdown;
 startup nomount pfile='D:\Oracle\admin\ngwd\pfile\init.ora';
 
 startup nomount pfile='.... init.ora'