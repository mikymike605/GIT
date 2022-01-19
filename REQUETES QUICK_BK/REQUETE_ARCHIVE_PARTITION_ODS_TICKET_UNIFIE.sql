BEGIN TRANSACTION
USE [SID_PRD]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ODS].[TICKET_UNIFIE_ARCHIVE](
	[RestaurantCode] [int] NULL,
	[RestaurantUniqueID] [int] NOT NULL,
	[InvoiceID] [bigint] NOT NULL,
	[InvoiceTransactionID] [bigint] NOT NULL,
	[CommercialDate] [date] NOT NULL,
	[CodePLU] [nvarchar](10) COLLATE French_CI_AS NULL,
	[RevenueDate] [date] NULL,
	[TITT_TaxeID] [int] NULL,
	[Pays_seq] [int] NULL,
	[CommercialMonth] [tinyint] NOT NULL,
	[TI_OpenDate] [datetime] NULL,
	[TI_CloseDate] [datetime] NULL,
	[Periode] [int] NULL,
	[CAT_RevenueCenterID] [int] NULL,
	[InvoiceNumber] [int] NULL,
	[FlagDeleted] [bit] NULL,
	[FlagPosted] [bit] NULL,
	[FlagTraining] [bit] NULL,
	[SID_PRODUCT] [int] NULL,
	[ParentInvoiceTransactionID] [bigint] NULL,
	[InCombo] [bit] NULL,
	[Quantity] [decimal](18, 6) NULL,
	[UnitPrice] [decimal](18, 6) NULL,
	[CA_Brut_TTC] [decimal](18, 6) NULL,
	[CA_BRut_TVA] [decimal](18, 6) NULL,
	[CA_Brut_HT] [decimal](18, 6) NULL,
	[Burst_CA_Brut_TTC] [decimal](18, 6) NULL,
	[Burst_CA_Brut_TVA] [decimal](18, 6) NULL,
	[Burst_CA_Brut_HT] [decimal](18, 6) NULL,
	[Disc_Count] [int] NULL,
	[Disc_TTC] [decimal](18, 6) NULL,
	[Disc_TVA] [decimal](18, 6) NULL,
	[Disc_HT] [decimal](18, 6) NULL,
	[Burst_Disc_TTC] [decimal](18, 6) NULL,
	[Burst_Disc_TVA] [decimal](18, 6) NULL,
	[Burst_Disc_HT] [decimal](18, 6) NULL,
	[BPub_Count] [int] NULL,
	[Bpub_TTC] [decimal](18, 6) NULL,
	[Bpub_TVA] [decimal](18, 6) NULL,
	[Bpub_HT] [decimal](18, 6) NULL,
	[BRepas_Count] [int] NULL,
	[BRepas_TTC] [decimal](18, 6) NULL,
	[BRepas_TVA] [decimal](18, 6) NULL,
	[BRepas_HT] [decimal](18, 6) NULL,
	[VA_TTC] [decimal](18, 6) NULL,
	[VA_TVA] [decimal](18, 6) NULL,
	[VA_HT] [decimal](18, 6) NULL,
	[CA_Net_TTC] [decimal](18, 6) NULL,
	[CA_Net_TVA] [decimal](18, 6) NULL,
	[CA_Net_HT] [decimal](18, 6) NULL,
	[Burst_CA_Net_TTC] [decimal](18, 6) NULL,
	[Burst_CA_Net_TVA] [decimal](18, 6) NULL,
	[Burst_CA_Net_HT] [decimal](18, 6) NULL,
	[Foodcost] [decimal](18, 6) NULL,
	[IsMainCombo] [bit] NULL,
	[TI_IsVoidReopenCheck] [bit] NULL,
	[TI_OrderDateTime] [datetime] NULL,
	[TI_SendDate] [datetime] NULL,
	[TI_PrintDate] [datetime] NULL,
	[TI_KitchenDate] [datetime] NULL,
	[TI_TotalSales] [decimal](18, 6) NULL,
	[TI_ReferenceInvoiceID] [bigint] NULL,
	[DWH_Process] [bit] NULL,
	[DT_INS] [datetime] NOT NULL,
	[DT_MAJ] [datetime] NOT NULL,
	[DT_SUP] [datetime] NULL,
	[SOURCE] [varchar](3) COLLATE French_CI_AS NOT NULL,
	[FLAG_DAY_CLOSING] [bit] NULL,
	[Description] [varchar](50) COLLATE French_CI_AS NULL
) ON [SID_PRD_ODS_FG30]

USE [SID_PRD]
CREATE NONCLUSTERED INDEX [TICKET_UNIFIE_ARCHIVE_IX_DATE_ID_UNIQUE] ON [ODS].[TICKET_UNIFIE_ARCHIVE]
(
	[CommercialDate] ASC
)
INCLUDE ( 	[RestaurantUniqueID]) WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SID_PRD_ODS_FG30]
USE [SID_PRD]
CREATE NONCLUSTERED INDEX [TICKET_UNIFIE_ARCHIVE_IX_SOURCE] ON [ODS].[TICKET_UNIFIE_ARCHIVE]
(
	[SOURCE] ASC,
	[CommercialDate] ASC
)
INCLUDE ( 	[RestaurantUniqueID]) WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SID_PRD_ODS_FG30]
USE [SID_PRD]
ALTER TABLE [ODS].[TICKET_UNIFIE_ARCHIVE] ADD  CONSTRAINT [TICKET_UNIFIE_ARCHIVE_PK_TICKET_UNIFIE] PRIMARY KEY NONCLUSTERED 
(
	[RestaurantUniqueID] ASC,
	[InvoiceID] ASC,
	[InvoiceTransactionID] ASC,
	[CommercialDate] ASC
)WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [SID_PRD_ODS_FG30]
USE [SID_PRD]
ALTER TABLE [ODS].[TICKET_UNIFIE_ARCHIVE]  WITH CHECK ADD  CONSTRAINT [chk_TICKET_UNIFIE_ARCHIVE_partition_1] CHECK  ([CommercialDate]<=N'2012-12-31')
ALTER TABLE [ODS].[TICKET_UNIFIE_ARCHIVE] CHECK CONSTRAINT [chk_TICKET_UNIFIE_ARCHIVE_partition_1]
ALTER TABLE [SID_PRD].[ODS].[TICKET_UNIFIE] SWITCH PARTITION 1 TO [SID_PRD].[ODS].[TICKET_UNIFIE_ARCHIVE] WITH (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES, ABORT_AFTER_WAIT = NONE))
COMMIT TRANSACTION



ALTER PARTITION FUNCTION FCT_SID_PRD_ODS_DATE () MERGE RANGE ('20121231')
GO

EXEC xp_cmdshell 'bcp.exe [SID_PRD].[ODS].[TICKET_UNIFIE_ARCHIVE] format nul -T -n -f \\KINGSIDSQLPRD\Share_SQL\FG.FMT -S KINGSIDSQLPRD'
EXEC xp_cmdshell 'bcp.exe "select * from [SID_PRD].[ODS].[TICKET_UNIFIE_ARCHIVE]" queryout "\\KINGSIDSQLPRD\Share_SQL\TICKET_UNIFIE_ARCHIVE_20121231.txt" -f "\\KINGSIDSQLPRD\Share_SQL\FG.FMT" -n -T -S'

--DROP TABLE myPartitionTableArchive
--GO


-- Split last partition by altering partition function
-- Note: When splitting a partition you need to use the following command before issuing the 
         ALTER PARTITION command however this is not needed for the first split command issued.
--    ALTER PARTITION SCHEME myPartitionScheme NEXT USED [PRIMARY]
ALTER PARTITION FUNCTION myDateRangePF () SPLIT RANGE ('20121001')
GO