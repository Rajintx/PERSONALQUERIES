 
ALTER PROCEDURE [dbo].[Nes_Customerwise_Sales_Report_ImporterLevel]
--DECLARE
        @DATE1 DATETIME='2020-03-01',
		@DATE2 DATETIME='2020-04-01',
		@IMPORTER VARCHAR(400)='%',
		@CUSTOMER VARCHAR(2000)='%',
		@BRAND VARCHAR(2000)='%',
		@PRODUCT VARCHAR(2000)='%'
as
--      set nocount on;
        --declare @DATE1 DATETIME='2023-01-01',@DATE2 DATETIME='2023-01-31',@IMPORTER VARCHAR(400)='%',@CUSTOMER VARCHAR(2000)='%',@BRAND VARCHAR(2000)='%',@PRODUCT VARCHAR(2000)='%'

		IF OBJECT_ID('TEMPDB..#TEMP') IS NOT NULL DROP TABLE #TEMP
        select Date,ASM,SO,[Importer Code],[Importer Name],[Customer Code],[Customer Name],[Customer Type],
               Brand,[Product Code],[Product Name],
        	   CASE WHEN ISNULL(MU.CONFACTOR,0)=0 THEN  0 else floor((Z.Quantity)/MU.CONFACTOR) END   [Quantity(Case)],
               CASE WHEN ISNULL(MU.CONFACTOR,0)=0 THEN  Z.Quantity else ((Z.Quantity)%MU.CONFACTOR) END  [Quantity(Each)],
        	   Amount,Volume [Volume(Kg)] INTO #TEMP
        from
              (SELECT CAST(TM.TRNDATE AS DATE) Date,ASM,SO,TM.companyid [Importer Code],RA.ACNAME [Importer Name],a.customerID [Customer Code],a.ACNAME [Customer Name],a.customer_type [Customer Type],
                     mi.BRANDCODE Brand,tp.mcode [Product Code],mi.DESCA [Product Name],
              	   SUM(case when left(tm.VCHRNO,2) in ('si','ti') then TP.RealQty else -TP.REALQTY_IN end) Quantity,
              	   SUM(case when left(tm.VCHRNO,2) in ('si','ti') then TP.NETAMOUNT else -TP.NETAMOUNT end) Amount,
              	   sum(case when left(TM.VCHRNO,2) in ('SC','RE','CN')
                     then -1 *(case when MI.Weighable in ('GRAM','ml','gm') then (TP.REALQTY_IN-TP.REALQTY)* MI.GWEIGHT/1000 else (TP.REALQTY_IN-TP.REALQTY)* MI.GWEIGHT end)
                     else (case when MI.Weighable in ('GRAM','ml','gm') then (TP.RealQty-TP.REALQTY_IN)* MI.GWEIGHT/1000 else (TP.RealQty-TP.REALQTY_IN)* MI.GWEIGHT end)  
                     end) Volume  
               FROM TRNMAIN TM JOIN TRNPROD TP ON  TM.VCHRNO=TP.VCHRNO AND TM.COMPANYID=TP.COMPANYID
                   JOIN RMD_WAREHOUSE RW ON TP.WAREHOUSE = RW.NAME and rw.WarehouseType = 'sellable'  JOIN
              	   (
                       SELECT companyid,geo,customerID,acname,A.ACID,ISNULL(ASM,PARENT) ASM,SO,customer_type
                       FROM
        			       (select  ra.companyid,ra.geo,ra.customerID,ra.acname,ra.ACID,
        			               case when rc.so like 'L5%' then rc.so end ASM,
        			               case when ra.so like 'L6%' then ra.so end SO,
                                   case when ra.GEO='123456-2' then'Distributor' when  ra.GEO='123456-3' then 'Direct Party' when  ra.GEO='111111-1' then 'Retailer' end customer_type
                            from RMD_ACLIST RA left join RMD_ACLIST rc on ra.COMPANYID=rc.customerID
                            where len(ra.COMPANYID)=2  --and ra.COMPANYID='NT001'
                            and ((@CUSTOMER='%' and ra.customerID like '%') or (@CUSTOMER <>'%' and ra.customerID in (select * from dbo.Split(@CUSTOMER,','))))
        			       )A  LEFT JOIN SALESOFFICERMASTER SM ON A.SO=SM.NAME

					)A ON TM.PARAC=A.ACID 
					LEFT JOIN (SELECT CUSTOMERID,ACNAME,GEO,PARENT FROM RMD_ACLIST  WITH (NOLOCK) )RA    ON RA.CUSTOMERID=TM.COMPANYID AND ISNULL(RA.GEO,'')<>''
              	   LEFT JOIN MENUITEM mi WITH (NOLOCK)on tp.mcode=mi.MCODE
        		   WHERE ((@PRODUCT='%' and TP.MCODE like '%') or (@PRODUCT <>'%' and TP.MCODE in (select * from dbo.Split(@PRODUCT,','))))
        		   AND ((@BRAND='%' and  MI.BRANDCODE like '%') or (@BRAND <>'%' and MI.BRANDCODE in (select * from dbo.Split(@BRAND,',')))) 
        		   AND  TRNDATE BETWEEN @DATE1 AND @DATE2
				   AND A.customerID NOT IN ('SubKM','SubNT')
				    and ((@IMPORTER='%' and TM.COMPANYID like '%') or (@IMPORTER <>'%' and TM.COMPANYID in (select * from dbo.Split(@IMPORTER,','))))


              	  group by CAST(TM.TRNDATE AS DATE) ,ASM,SO,TM.companyid,RA.ACNAME,a.customerID,a.ACNAME,a.customer_type,mi.BRANDCODE ,tp.mcode ,mi.DESCA)z 
               join MULTIALTUNIT mu on mu.MCODE=z.[Product Code] and mu.ALTUNIT='CASE'
        	  order by date

			 
			 SELECT DATE,ASM,SO,[Importer Code],[Importer Name],[Customer Code],[Customer Name],[Customer Type],Brand,[Product Code],[Product Name],[Quantity(Case)],[Quantity(Each)],Amount,[Volume(Kg)]  FROM (

			  SELECT * , 1 ORD FROM #TEMP

			  UNION ALL 

			  SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,CAST(SUM([Quantity(Case)]) AS NUMERIC(18,2)),CAST(SUM([Quantity(Each)]) AS NUMERIC(18,2)),CAST(SUM (Amount ) AS NUMERIC(18,2)),CAST(SUM([Volume(Kg)]) AS NUMERIC(18,2)) ,2 ORD  FROM #TEMP
			  )A
			  ORDER BY ORD,Date
        
        	  	  
