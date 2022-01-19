/* SQL Server Automated Configuration Script
   2009 - Rodney Landrum
*/

--Create Temp table #SerProp. This table will be used
--to hold the output of xp_msver to control server property configurations

SET NOCOUNT ON
GO

IF EXISTS ( SELECT  name
            FROM    tempdb..sysobjects
            Where   name like '#SerProp%' )
--If So Drop it
    DROP TABLE #SerProp
create table #SerProp
    (
      ID int,
      Name sysname,
      Internal_Value int,
      Value nvarchar(512)
    )
    
  GO
 

--Set Show Advanced Option
sp_configure 'Show Advanced Options', 1
Reconfigure
GO

DECLARE @PhysMem int
DECLARE @ProcType int
DECLARE @MaxMem int

 
INSERT  INTO #SerProp
        Exec xp_msver
 
Select  @PhysMem = Internal_Value
from    #SerProp
where   Name = 'PhysicalMemory'

Select  @ProcType = Internal_Value
from    #SerProp
where   Name = 'ProcessorType'

--Set Memory Configuration from server properties
--(memory level and processortype)

If @PhysMem > 4096 AND @ProcType = 8664
BEGIN
   SET @MaxMem = @PhysMem - 3072
   EXEC sp_configure 'max server memory', @MaxMem
   Reconfigure
END   

ELSE
IF @PhysMem > 4096 AND @ProcType <> 8664
BEGIN
   SET @MaxMem = @PhysMem - 3072
   EXEC sp_configure 'awe enabled', 1
   Reconfigure
   EXEC sp_configure 'max server memory', @MaxMem
   Reconfigure
END  