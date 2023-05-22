---sbl pro
 
select   ssm.NAME,c.salesmanid,a.MCODE,b.mcat1 ,c.trnac CUSTOMER from rmd_TRNPROd a with (nolock) join menuitem b with (nolock) on a.mcode=b.mcode
join TRNMAIN c with (nolock) on c.VCHRNO=a.VCHRNO

left join salesman ssm on ssm.salesmanid=c.SALESMANID

where c.SALESMANID is not null


select * from salesman 
 


  select SALESMANID,* from RMD_ACLIST