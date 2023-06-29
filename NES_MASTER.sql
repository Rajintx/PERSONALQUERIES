 
ALTER   PROCEDURE [dbo].[Nes_MASTER_REPORT_PRIMARY]
----   declare

		@DATE1 DATETIME,
		@DATE2 DATETIME,
		@RETAILER VARCHAR(2000)='%',
		@BRAND VARCHAR(2000)='%',
		@PRODUCT VARCHAR(2000)='%',
		@ASM VARCHAR(500)='%',
		@SO VARCHAR(500)='%',
		@BUSINESSUNIT VARCHAR(2000)='%',
		@DIRECTPARTY VARCHAR(2000)='%',
        @DISTRIBUTOR VARCHAR(2000)='%',
		@CHANNEL VARCHAR(2000)='%',
		@MOTHERPACK VARCHAR(2000)='%'
as
      set nocount on;
          --declare @DATE1 DATETIME='2023-05-16',@DATE2 DATETIME='2023-05-16',@RETAILER VARCHAR(2000)='%',@DIRECTPARTY VARCHAR(2000)='%',@DISTRIBUTOR VARCHAR(2000)='%',@BRAND VARCHAR(2000)='%',@MOTHERPACK VARCHAR(2000)='%',@PRODUCT VARCHAR(2000)='%',@ASM VARCHAR(500)='%',@SO VARCHAR(500)='%',@BUSINESSUNIT VARCHAR(2000)='%',@CHANNEL VARCHAR(2000)='%'


		IF OBJECT_ID('TEMPDB..#TRNMAIN') is not null drop table #TRNMAIN
		select tm.VCHRNO,TRNDATE,tm.COMPANYID,isnull(sm.name,'') salesman,PARAC into #TRNMAIN 
		from  trnmain TM  WITH (NOLOCK) left join SALESMAN sm on tm.COMPANYID = sm.COMPANYID and tm.SALESMANID = sm.SALESMANID
		where TRNDATE BETWEEN @DATE1 AND @DATE2 and len(tm.COMPANYID)=2
		

		IF OBJECT_ID('TEMPDB..#report') is not null drop table #report
       SELECT DATE, ASM, SO,salesman PSM, [Importer Code], [Importer Name], [Customer Code], [Customer Name], [Customer Type], ISNULL(bd.division,'') [Business],BD.verticalname Brand, BD.BRANDname [Motherpack],[Product Code], [Product Name],SalesQty [Sales Qty (Ea)],ReturnQty [Return Qty (Ea)],NetQty [Net Qty (Ea)],salesvolume [Sales Vol (Kgs)],returnvolume [Return Vol (Kgs)],Volume [Net Vol (Kgs)],SALESAmount [Sales Value],SALESVAT [Sales Tax],RETURNAmount [Return Value],RETURNVAT [Return Tax],grossamount [Gross Value],vat Tax,amount [Net Value],billcount [Bills Cut]
into #report
FROM (
	SELECT 
	CAST(TM.TRNDATE AS DATE) DATE, A.ASM, A.SO, TM.companyid [Importer Code], RA.ACNAME   [Importer Name], a.customerID [Customer Code], a.ACNAME [Customer Name], a.customer_type [Customer Type], mi.BRANDCODE Brand ,mi.BRAND mother,tp.mcode [Product Code], mi.DESCA [Product Name] ,tm.salesman,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.RealQty ELSE - TP.REALQTY_IN END) Quantity,
	SUM(CASE WHEN LEFT(TM.VCHRNO, 2) IN ('SI', 'TI') THEN TP.REALQTY WHEN LEFT(TM.VCHRNO,2) = 'RE' THEN -TP.REALQTY_IN ELSE 0 END) SALESQTY,
	SUM(CASE WHEN LEFT(TM.VCHRNO, 2) IN ('CN') THEN TP.REALQTY_IN WHEN LEFT(TM.VCHRNO,2) = 'RR' THEN TP.REALQTY ELSE 0 END) RETURNQTY,
	SUM(CASE WHEN LEFT(TM.VCHRNO, 2) IN ('SI', 'TI','RR') THEN TP.REALQTY WHEN LEFT(TM.VCHRNO,2) IN ('CN','RE') THEN -TP.REALQTY_IN ELSE 0 END) NETQTY,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.NETAMOUNT ELSE - TP.NETAMOUNT END) Amount,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.AMOUNT WHEN  left(tm.VCHRNO, 2) IN ('RE') THEN - TP.AMOUNT ELSE 0 END) SALESAmount, 
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('CN') THEN TP.AMOUNT WHEN  left(tm.VCHRNO, 2) IN ('RR') THEN - TP.AMOUNT ELSE 0 END) RETURNAmount,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.AMOUNT ELSE - TP.AMOUNT END) GROSSAmount,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.VAT ELSE - TP.VAT END) VAT,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.VAT WHEN  left(tm.VCHRNO, 2) IN ('RE') THEN - TP.VAT ELSE 0 END) SALESVAT, 
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('CN') THEN TP.VAT WHEN  left(tm.VCHRNO, 2) IN ('RR') THEN - TP.VAT ELSE 0 END) RETURNVAT,
	SUM(CASE WHEN left(tm.VCHRNO, 2) IN ('si', 'ti') THEN TP.VAT ELSE - TP.VAT END) GROSSVAT,
	SUM(CASE WHEN LEFT(TM.VCHRNO, 2) IN ('SI', 'TI') THEN 1 else 0 end) billcount,
	sum(CASE WHEN left(TM.VCHRNO, 2) IN ('RE') THEN - 1 * REALQTY_IN * (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN CAST(MI.GWEIGHT AS NUMERIC(18,5))/1000 ELSE CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) WHEN LEFT(TM.VCHRNO, 2) IN ('SI', 'TI') THEN REALQTY * (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN  CAST(MI.GWEIGHT AS NUMERIC(18,5))/1000 ELSE CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) ELSE 0 END) SALESVOLUME,
	sum(CASE WHEN left(TM.VCHRNO, 2) IN ('RR') THEN - 1 * REALQTY * (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN CAST(MI.GWEIGHT AS NUMERIC(18,5))/1000 ELSE CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) WHEN LEFT(TM.VCHRNO, 2) IN ('CN') THEN REALQTY_IN * (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN  CAST(MI.GWEIGHT AS NUMERIC(18,5))/1000 ELSE CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) ELSE 0 END) RETURNVOLUME,
	sum(CASE WHEN left(TM.VCHRNO, 2) IN ('SC', 'RE', 'CN') THEN - 1 * (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN (TP.REALQTY_IN - TP.REALQTY) * CAST(MI.GWEIGHT AS NUMERIC(18,5)) / 1000 ELSE (TP.REALQTY_IN - TP.REALQTY) * CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) ELSE (CASE WHEN MI.Weighable IN ('GRAM', 'ml', 'gm') THEN (TP.RealQty - TP.REALQTY_IN) * CAST(MI.GWEIGHT AS NUMERIC(18,5)) / 1000 ELSE (TP.RealQty - TP.REALQTY_IN) * CAST(MI.GWEIGHT AS NUMERIC(18,5)) END) END) Volume
	FROM #TRNMAIN TM 
	INNER JOIN trnprod TP WITH (NOLOCK) ON TM.VCHRNO = TP.VCHRNO AND TM.COMPANYID = TP.COMPANYID
	INNER JOIN (  
	 
			SELECT  companyid, geo, customerID, acname, A.ACID, ISNULL(ASM, PARENT) ASM, SO, customer_type
				FROM ( SELECT ra.companyid, ra.geo, ra.customerID, ra.acname, ra.ACID, CASE WHEN rc.so LIKE 'L5%' THEN rc.so END ASM, CASE WHEN ra.so LIKE 'L6%' THEN ra.so END SO, CASE WHEN ra.GEO = '123456-2' THEN 'Distributor' WHEN ra.GEO = '123456-3' THEN 'Direct Party' WHEN ra.GEO = '111111-1' THEN 'Retailer' END customer_type FROM RMD_ACLIST RA WITH (NOLOCK) 
			LEFT JOIN RMD_ACLIST rc WITH (NOLOCK) ON ra.COMPANYID = rc.customerID WHERE len(ra.COMPANYID) = 2 AND ((@CHANNEL='%' AND ISNULL(RA.Channel,'') LIKE '%') OR (@CHANNEL<>'%' AND RA.Channel IN (SELECT * FROM DBO.Split(@CHANNEL,',')))) AND ((@RETAILER ='%' AND @Distributor='%' AND @Directparty='%' AND ISNULL(RA.CUSTOMERID,'') LIKE '%') OR ((@RETAILER<>'%' OR @Distributor<>'%' OR @Directparty<>'%') AND ((@RETAILER <>'%' AND RA.CUSTOMERID IN (SELECT * FROM DBO.SPLIT(@RETAILER,',')))OR(@Distributor <>'%' AND RA.CUSTOMERID IN (SELECT * FROM DBO.SPLIT(@Distributor,',')))OR(@Directparty <>'%' AND RA.CUSTOMERID IN (SELECT * FROM DBO.SPLIT(@Directparty,',')))))) ) A 
			LEFT JOIN SALESOFFICERMASTER SM WITH (NOLOCK) ON A.SO = SM.NAME 
			
		) A ON TM.PARAC = A.ACID
	LEFT JOIN RMD_ACLIST RA   WITH (NOLOCK)  ON RA.CUSTOMERID=TM.COMPANYID AND ISNULL(RA.GEO,'')<>''
	LEFT JOIN MENUITEM mi    WITH (NOLOCK) ON tp.mcode = mi.MCODE
	WHERE ((@PRODUCT = '%' AND TP.MCODE LIKE '%') OR ( @PRODUCT <> '%' AND TP.MCODE IN ( SELECT * FROM dbo.Split(@PRODUCT, ',') ) ) ) AND (
			(@BRAND = '%' AND MI.BRANDCODE LIKE '%') OR ( @BRAND <> '%' AND MI.BRANDCODE IN ( SELECT * FROM dbo.Split(@BRAND, ',') ) ) ) AND TP.WAREHOUSE IN ('Main Warehouse')
			and ((@ASM = '%' AND 1=1) OR (@ASM <> '%' AND A.ASM IN (SELECT * FROM DBO.Split(@ASM,','))))
			AND ((@SO = '%' AND 1=1) OR (@SO <> '%' AND A.SO IN (SELECT * FROM DBO.Split(@SO,','))))
			 AND A.customerID NOT IN ('SubKM','SubNT')

	GROUP BY CAST(TM.TRNDATE AS DATE), A.ASM, A.SO, TM.companyid, RA.ACNAME,tm.salesman, a.customerID, a.ACNAME, a.customer_type, mi.BRANDCODE, tp.mcode, mi.DESCA,mi.BRAND
) z
LEFT JOIN MULTIALTUNIT mu
ON mu.MCODE = z.[Product Code] AND mu.ALTUNIT = 'CASE'
left join (select distinct bd.PARENTBRANDCODE division , bd.brandcode vertical , bd.brandname verticalname, bdd.brandcode , bdd.BrandName from BRAND bd 
 JOIN BRAND BDD ON BDD.PARENTBRANDCODE = BD.BRANDCODE AND BdD.TYPE = 'BRAND' and BD.TYPE='VERTICAL' ) bd on z.Brand = bd.vertical and z.mother = bd.BRANDCODE
WHERE ((@BUSINESSUNIT='%' AND ISNULL(BD.division,'') LIKE '%') OR (@BUSINESSUNIT<>'%' AND BD.division IN (SELECT * FROM DBO.Split(@BUSINESSUNIT,','))))
					AND ((@MOTHERPACK='%' AND ISNULL(BD.BRANDCODE,'') LIKE @MOTHERPACK) OR (@MOTHERPACK <> '%' AND BD.BRANDCODE IN (SELECT * FROM DBO.Split(@MOTHERPACK,','))))


					select  DATE,  ASM, SO, PSM, [Importer Code], [Importer Name], [Customer Code], [Customer Name], [Customer Type],  [Business], Brand,  [Motherpack], [Product Code] ,[Product Name],   [Sales Qty (Ea)],   [Return Qty (Ea)],   [Net Qty (Ea)],   [Sales Vol (Kgs)],   [Return Vol (Kgs)],   [Net Vol (Kgs)],   [Sales Value],   [Sales Tax],   [Return Value],   [Return Tax],   [Gross Value],  Tax,   [Net Value],    [Bills Cut] 
					from (
					select  DATE,  ASM, SO, PSM, [Importer Code], [Importer Name], [Customer Code], [Customer Name], [Customer Type],  [Business], Brand,  [Motherpack], [Product Code] ,[Product Name],cast( [Sales Qty (Ea)]  as numeric(18,2))[Sales Qty (Ea)],cast( [Return Qty (Ea)]  as numeric(18,2))[Return Qty (Ea)],cast( [Net Qty (Ea)]  as numeric(18,2))[Net Qty (Ea)],cast( [Sales Vol (Kgs)]  as numeric(18,2))[Sales Vol (Kgs)],cast( [Return Vol (Kgs)]  as numeric(18,2))[Return Vol (Kgs)],cast( [Net Vol (Kgs)]  as numeric(18,2))[Net Vol (Kgs)],cast( [Sales Value]  as numeric(18,2))[Sales Value],cast( [Sales Tax]  as numeric(18,2))[Sales Tax],cast( [Return Value]  as numeric(18,2))[Return Value],cast( [Return Tax]  as numeric(18,2))[Return Tax],cast( [Gross Value]  as numeric(18,2))[Gross Value],cast( Tax as numeric(18,2))Tax,cast( [Net Value]  as numeric(18,2))[Net Value],cast( [Bills Cut]  as int) [Bills Cut],'A' flg from #report
					union all
					SELECT null DATE, null ASM,null SO,null PSM,null [Importer Code],null [Importer Name],null [Customer Code],null [Customer Name],null [Customer Type], null [Business],null Brand, null [Motherpack],null [Product Code],'TOTAL' [Product Name],cast(sum([Sales Qty (Ea)]) as numeric(18,2))[Sales Qty (Ea)],cast(sum([Return Qty (Ea)]) as numeric(18,2))[Return Qty (Ea)],cast(sum([Net Qty (Ea)]) as numeric(18,2))[Net Qty (Ea)],cast(sum([Sales Vol (Kgs)]) as numeric(18,2))[Sales Vol (Kgs)],cast(sum([Return Vol (Kgs)]) as numeric(18,2))[Return Vol (Kgs)],cast(sum([Net Vol (Kgs)]) as numeric(18,2))[Net Vol (Kgs)],cast(sum([Sales Value]) as numeric(18,2))[Sales Value],cast(sum([Sales Tax]) as numeric(18,2))[Sales Tax],cast(sum([Return Value]) as numeric(18,2))[Return Value],cast(sum([Return Tax]) as numeric(18,2))[Return Tax],cast(sum([Gross Value]) as numeric(18,2))[Gross Value],cast(sum(Tax) as numeric(18,2))Tax,cast(sum([Net Value]) as numeric(18,2))[Net Value],cast(sum([Bills Cut]) as int) [Bills Cut] ,'B' FLG  from #report
					) a
					ORDER BY FLG ASC, DATE ASC, [Importer Name] ASC, [Customer Name] ASC, [Product Name] ASC





