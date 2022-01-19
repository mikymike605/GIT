USE [DBAtools]
GO

ALTER TABLE [dbo].[BlitzFirst_WaitStats_Categories] DROP CONSTRAINT [DF__BlitzFirs__Ignor__239E4DCF]
GO

/****** Object:  Table [dbo].[DBA_IndexStatistics]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[DBA_IndexStatistics]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats_Categories]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_WaitStats_Categories]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_WaitStats_Archive]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_WaitStats]
GO

/****** Object:  Table [dbo].[BlitzFirst_PerfmonStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_PerfmonStats_Archive]
GO

/****** Object:  Table [dbo].[BlitzFirst_PerfmonStats]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_PerfmonStats]
GO

/****** Object:  Table [dbo].[BlitzFirst_FileStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_FileStats_Archive]
GO

/****** Object:  Table [dbo].[BlitzFirst_FileStats]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_FileStats]
GO

/****** Object:  Table [dbo].[BlitzFirst_Archive]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst_Archive]
GO

/****** Object:  Table [dbo].[BlitzFirst]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzFirst]
GO

/****** Object:  Table [dbo].[BlitzCache_Archive]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzCache_Archive]
GO

/****** Object:  Table [dbo].[BlitzCache]    Script Date: 18/06/2018 15:18:21 ******/
DROP TABLE [dbo].[BlitzCache]
GO

/****** Object:  Table [dbo].[BlitzCache]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzCache](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](258) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Version] [nvarchar](258) NULL,
	[QueryType] [nvarchar](258) NULL,
	[Warnings] [varchar](max) NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SerialDesiredMemory] [float] NULL,
	[SerialRequiredMemory] [float] NULL,
	[AverageCPU] [bigint] NULL,
	[TotalCPU] [bigint] NULL,
	[PercentCPUByType] [money] NULL,
	[CPUWeight] [money] NULL,
	[AverageDuration] [bigint] NULL,
	[TotalDuration] [bigint] NULL,
	[DurationWeight] [money] NULL,
	[PercentDurationByType] [money] NULL,
	[AverageReads] [bigint] NULL,
	[TotalReads] [bigint] NULL,
	[ReadWeight] [money] NULL,
	[PercentReadsByType] [money] NULL,
	[AverageWrites] [bigint] NULL,
	[TotalWrites] [bigint] NULL,
	[WriteWeight] [money] NULL,
	[PercentWritesByType] [money] NULL,
	[ExecutionCount] [bigint] NULL,
	[ExecutionWeight] [money] NULL,
	[PercentExecutionsByType] [money] NULL,
	[ExecutionsPerMinute] [money] NULL,
	[PlanCreationTime] [datetime] NULL,
	[PlanCreationTimeHours]  AS (datediff(hour,[PlanCreationTime],sysdatetime())),
	[LastExecutionTime] [datetime] NULL,
	[PlanHandle] [varbinary](64) NULL,
	[Remove Plan Handle From Cache]  AS (case when [PlanHandle] IS NOT NULL then ('DBCC FREEPROCCACHE ('+CONVERT([varchar](128),[PlanHandle],(1)))+');' else 'N/A' end),
	[SqlHandle] [varbinary](64) NULL,
	[Remove SQL Handle From Cache]  AS (case when [SqlHandle] IS NOT NULL then ('DBCC FREEPROCCACHE ('+CONVERT([varchar](128),[SqlHandle],(1)))+');' else 'N/A' end),
	[SQL Handle More Info]  AS (case when [SqlHandle] IS NOT NULL then ('EXEC sp_BlitzCache @OnlySqlHandles = '''+CONVERT([varchar](128),[SqlHandle],(1)))+'''; ' else 'N/A' end),
	[QueryHash] [binary](8) NULL,
	[Query Hash More Info]  AS (case when [QueryHash] IS NOT NULL then ('EXEC sp_BlitzCache @OnlyQueryHashes = '''+CONVERT([varchar](32),[QueryHash],(1)))+'''; ' else 'N/A' end),
	[QueryPlanHash] [binary](8) NULL,
	[StatementStartOffset] [int] NULL,
	[StatementEndOffset] [int] NULL,
	[MinReturnedRows] [bigint] NULL,
	[MaxReturnedRows] [bigint] NULL,
	[AverageReturnedRows] [money] NULL,
	[TotalReturnedRows] [bigint] NULL,
	[QueryText] [nvarchar](max) NULL,
	[QueryPlan] [xml] NULL,
	[NumberOfPlans] [int] NULL,
	[NumberOfDistinctPlans] [int] NULL,
	[MinGrantKB] [bigint] NULL,
	[MaxGrantKB] [bigint] NULL,
	[MinUsedGrantKB] [bigint] NULL,
	[MaxUsedGrantKB] [bigint] NULL,
	[PercentMemoryGrantUsed] [money] NULL,
	[AvgMaxMemoryGrant] [money] NULL,
	[MinSpills] [bigint] NULL,
	[MaxSpills] [bigint] NULL,
	[TotalSpills] [bigint] NULL,
	[AvgSpills] [money] NULL,
	[QueryPlanCost] [float] NULL,
 CONSTRAINT [PK_CAC92CCB-626E-4DDB-A0F3-4C1C3F4E40EF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzCache_Archive]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzCache_Archive](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](258) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Version] [nvarchar](258) NULL,
	[QueryType] [nvarchar](258) NULL,
	[Warnings] [varchar](max) NULL,
	[DatabaseName] [sysname] NOT NULL,
	[SerialDesiredMemory] [float] NULL,
	[SerialRequiredMemory] [float] NULL,
	[AverageCPU] [bigint] NULL,
	[TotalCPU] [bigint] NULL,
	[PercentCPUByType] [money] NULL,
	[CPUWeight] [money] NULL,
	[AverageDuration] [bigint] NULL,
	[TotalDuration] [bigint] NULL,
	[DurationWeight] [money] NULL,
	[PercentDurationByType] [money] NULL,
	[AverageReads] [bigint] NULL,
	[TotalReads] [bigint] NULL,
	[ReadWeight] [money] NULL,
	[PercentReadsByType] [money] NULL,
	[AverageWrites] [bigint] NULL,
	[TotalWrites] [bigint] NULL,
	[WriteWeight] [money] NULL,
	[PercentWritesByType] [money] NULL,
	[ExecutionCount] [bigint] NULL,
	[ExecutionWeight] [money] NULL,
	[PercentExecutionsByType] [money] NULL,
	[ExecutionsPerMinute] [money] NULL,
	[PlanCreationTime] [datetime] NULL,
	[LastExecutionTime] [datetime] NULL,
	[PlanHandle] [varbinary](64) NULL,
	[SqlHandle] [varbinary](64) NULL,
	[QueryHash] [binary](8) NULL,
	[QueryPlanHash] [binary](8) NULL,
	[StatementStartOffset] [int] NULL,
	[StatementEndOffset] [int] NULL,
	[MinReturnedRows] [bigint] NULL,
	[MaxReturnedRows] [bigint] NULL,
	[AverageReturnedRows] [money] NULL,
	[TotalReturnedRows] [bigint] NULL,
	[QueryText] [nvarchar](max) NULL,
	[QueryPlan] [xml] NULL,
	[NumberOfPlans] [int] NULL,
	[NumberOfDistinctPlans] [int] NULL,
	[MinGrantKB] [bigint] NULL,
	[MaxGrantKB] [bigint] NULL,
	[MinUsedGrantKB] [bigint] NULL,
	[MaxUsedGrantKB] [bigint] NULL,
	[PercentMemoryGrantUsed] [money] NULL,
	[AvgMaxMemoryGrant] [money] NULL,
	[MinSpills] [bigint] NULL,
	[MaxSpills] [bigint] NULL,
	[TotalSpills] [bigint] NULL,
	[AvgSpills] [money] NULL,
	[QueryPlanCost] [float] NULL,
	[PlanCreationTimeHours] [int] NULL,
	[Remove Plan Handle From Cache] [varchar](max) NULL,
	[Remove SQL Handle From Cache] [varchar](max) NULL,
	[SQL Handle More Info] [varchar](max) NULL,
	[Query Hash More Info] [varchar](max) NULL,
 CONSTRAINT [PK_CAC92CCB-626E-4DDB-A0F3-4C1C3F4E40EF_Archive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[FindingsGroup] [varchar](50) NOT NULL,
	[Finding] [varchar](200) NOT NULL,
	[URL] [varchar](200) NOT NULL,
	[Details] [nvarchar](4000) NULL,
	[HowToStopIt] [xml] NULL,
	[QueryPlan] [xml] NULL,
	[QueryText] [nvarchar](max) NULL,
	[StartTime] [datetimeoffset](7) NULL,
	[LoginName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[OriginalLoginName] [nvarchar](128) NULL,
	[ProgramName] [nvarchar](128) NULL,
	[HostName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[OpenTransactionCount] [int] NULL,
	[DetailsInt] [int] NULL,
 CONSTRAINT [PK_BA6983A1-7754-4894-8468-1891B4BBAF5B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_Archive]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_Archive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[CheckID] [int] NOT NULL,
	[Priority] [tinyint] NOT NULL,
	[FindingsGroup] [varchar](50) NOT NULL,
	[Finding] [varchar](200) NOT NULL,
	[URL] [varchar](200) NOT NULL,
	[Details] [nvarchar](4000) NULL,
	[HowToStopIt] [xml] NULL,
	[QueryPlan] [xml] NULL,
	[QueryText] [nvarchar](max) NULL,
	[StartTime] [datetimeoffset](7) NULL,
	[LoginName] [nvarchar](128) NULL,
	[NTUserName] [nvarchar](128) NULL,
	[OriginalLoginName] [nvarchar](128) NULL,
	[ProgramName] [nvarchar](128) NULL,
	[HostName] [nvarchar](128) NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[OpenTransactionCount] [int] NULL,
	[DetailsInt] [int] NULL,
 CONSTRAINT [PK_BA6983A1-7754-4894-8468-1891B4BBAF5B_Archive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_FileStats]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_FileStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[DatabaseID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
	[DatabaseName] [nvarchar](256) NULL,
	[FileLogicalName] [nvarchar](256) NULL,
	[TypeDesc] [nvarchar](60) NULL,
	[SizeOnDiskMB] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[bytes_read] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[bytes_written] [bigint] NULL,
	[PhysicalName] [nvarchar](520) NULL,
 CONSTRAINT [PK_D5B4DB87-7D97-422B-80A0-64613176DD36] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_FileStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_FileStats_Archive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[DatabaseID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
	[DatabaseName] [nvarchar](256) NULL,
	[FileLogicalName] [nvarchar](256) NULL,
	[TypeDesc] [nvarchar](60) NULL,
	[SizeOnDiskMB] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[bytes_read] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[bytes_written] [bigint] NULL,
	[PhysicalName] [nvarchar](520) NULL,
 CONSTRAINT [PK_D5B4DB87-7D97-422B-80A0-64613176DD36_Archive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_PerfmonStats]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_PerfmonStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[object_name] [nvarchar](128) NOT NULL,
	[counter_name] [nvarchar](128) NOT NULL,
	[instance_name] [nvarchar](128) NULL,
	[cntr_value] [bigint] NULL,
	[cntr_type] [int] NOT NULL,
	[value_delta] [bigint] NULL,
	[value_per_second] [decimal](18, 2) NULL,
 CONSTRAINT [PK_84D5B022-D201-462E-B3A8-AAAF4BC017E1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_PerfmonStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_PerfmonStats_Archive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[object_name] [nvarchar](128) NOT NULL,
	[counter_name] [nvarchar](128) NOT NULL,
	[instance_name] [nvarchar](128) NULL,
	[cntr_value] [bigint] NULL,
	[cntr_type] [int] NOT NULL,
	[value_delta] [bigint] NULL,
	[value_per_second] [decimal](18, 2) NULL,
 CONSTRAINT [PK_84D5B022-D201-462E-B3A8-AAAF4BC017E1_Archive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_WaitStats](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time_ms] [bigint] NULL,
	[signal_wait_time_ms] [bigint] NULL,
	[waiting_tasks_count] [bigint] NULL,
 CONSTRAINT [PK_2F24684D-7AF4-420F-B476-A86F1BE6C3BE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats_Archive]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_WaitStats_Archive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[wait_type] [nvarchar](60) NULL,
	[wait_time_ms] [bigint] NULL,
	[signal_wait_time_ms] [bigint] NULL,
	[waiting_tasks_count] [bigint] NULL,
 CONSTRAINT [PK_2F24684D-7AF4-420F-B476-A86F1BE6C3BE_Archive] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlitzFirst_WaitStats_Categories]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlitzFirst_WaitStats_Categories](
	[WaitType] [nvarchar](60) NOT NULL,
	[WaitCategory] [nvarchar](128) NOT NULL,
	[Ignorable] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[WaitType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[DBA_IndexStatistics]    Script Date: 18/06/2018 15:18:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DBA_IndexStatistics](
	[Object_Id] [int] NULL,
	[Table_Nm] [varchar](255) NULL,
	[Index_Id] [int] NULL,
	[Index_Nm] [varchar](255) NULL,
	[Frag] [float] NULL,
	[IndexRebuilt_Ind] [bit] NULL,
	[Start_DtTm] [datetime] NULL,
	[End_DtTm] [datetime] NULL,
	[Duration] [varchar](20) NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BlitzFirst_WaitStats_Categories] ADD  DEFAULT ((0)) FOR [Ignorable]
GO


