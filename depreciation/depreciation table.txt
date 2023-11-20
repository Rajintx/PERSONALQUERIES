 IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='DEPRECIATION')
CREATE TABLE [dbo].[Depreciation](
	[AssetID] [varchar](100) NOT NULL,
	[MCODE] [varchar](200) NOT NULL,
	[BATCHCODE] [varchar](200) NOT NULL,
	[BOOKVALUE] [numeric](32, 2) NULL,
	[NETBOOKVALUE] [numeric](32, 2) NULL,
	[ORIGNALCOST] [numeric](32, 2) NULL,
	[MON] [int] NULL,
	[DEPRECIATION_VALUE] [float] NULL,
	[PHISCALID] [varchar](25) NULL,
	[ACID] [varchar](200) NULL,
	[DIVISION] [varchar](3) NULL,
	[TRNTIME] [varchar](15) NULL,
	[TRNUSER] [varchar](25) NULL,
	[RefVchrNo] [varchar](100) NULL,
	[PCL] [varchar](6) NULL,
	[trn_date] [datetime] NULL,
	[bs_date] [varchar](100) NULL,
	[Stamp] [float] NULL,
	[Companyid] [varchar](100) NULL,
	[DEPRECIATIONRATE] [numeric](18, 2) NULL
) ON [PRIMARY]
GO


