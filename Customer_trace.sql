
SELECT  a.c_br_code,replace(a.c_br_name,',','-') as c_br_name,a.c_cust_code,replace(a.c_cust_name,',','-') as c_cust_name,a.c_msme_no,isnull(settle_mst_header.c_trans,a.c_trans) as  c_trans,(a.c_br_code+'/'+a.C_YEAR1+'/'+a.C_PREFIX1+'/'+STRING(a.N_SRNO1)) AS TRANNO
,isnull(Inv_amt.d_date,a.d_date) as  Tran_date,
replace(isnull(settle_mst_header.c_ref_no,jv_mst.c_remark),',','-') as  Inv_no,isnull(settle_mst_header.d_ref_date,jv_mst.d_ref_date) as Inv_dt,DATE(isnull(settle_mst_header.d_due_date,
isnull(settle_mst_header.d_lr_date,Tran_date))) AS d_due_date,isnull(Inv_amt.n_amount,settle_mst_header.n_total) as Invs_amt,a.n_amount as  BalanceAmt,
settle_mst.c_br_code,settle_mst.c_year,settle_mst.c_prefix,settle_mst.n_srno,settle_mst.n_amount,settle_mst.d_date,		supp_pay_mst.c_chq_no,
		supp_pay_mst.d_chq_dt


 FROM (
SELECT settle_mst.c_br_code1 as c_br_code,   
         settle_mst.c_year1,   
         settle_mst.c_prefix1,   
         settle_mst.n_srno1,   
			(IF LEFT((SELECT max(prefix_srno.c_trans) FROM prefix_srno WHERE prefix_srno.c_prefix = settle_mst.c_prefix1 ), 3) = 'INV' then  act_mst_a.n_debit_days ELSE 0 endif) as n_days,
         sum(settle_mst.n_amount) as n_amount,   
         sum(0.00) as n_amount1,   
         (SELECT max(prefix_srno.c_trans) FROM prefix_srno WHERE prefix_srno.c_prefix = settle_mst.c_prefix1 ) as c_trans,   
         settle_mst.c_cust_code,   
         act_mst_a.c_name as c_cust_name,   
            act_mst_a.c_msme_no as c_msme_no,    
         act_mst_b.c_name as c_br_name,
			(IF LEFT((SELECT max(prefix_srno.c_trans) FROM prefix_srno WHERE prefix_srno.c_prefix = settle_mst.c_prefix1 ), 3) = 'INV' then  0 ELSE 1 endif) as n1,
			max(settle_mst.d_Date) as d_date,
			( SELECT max(a.d_date)  FROM settle_mst  a  where a.c_br_code = settle_mst.c_br_code1 and
														a.c_year = settle_mst.c_year1 and   
														a.c_prefix = settle_mst.c_prefix1 and   
														a.n_srno = settle_mst.n_srno1 ) as d_inv_date,
														    

(if ((left('',3) = '-CG'OR left('',3) = '-SG' ) and (left('',3) = '-CG'OR left('',3) = '-SG')) then cust_supp_group_det.c_code else  settle_mst.c_cust_code end if) as as_cust_cg 
    FROM settle_mst 	left outer join cust_supp_group_det on ( cust_supp_group_det.c_cust_supp_code =settle_mst.c_cust_code) and
                                          ( cust_supp_group_det.n_cancel_flag=0),
         act_mst act_mst_a,   
         act_mst act_mst_b  
   WHERE ( settle_mst.c_cust_code = act_mst_a.c_code ) and  
         ( settle_mst.c_br_code1 = act_mst_b.c_code ) and  
         ( ( settle_mst.d_date <= Today() ) and
			( act_mst_a.n_type in(4,2) ) and
			( settle_mst.c_br_code1 in 
			( if length('BG0015') = 6 then 
				( select c_br_code from branch_group_det where c_code = 'BG0015' and 
						branch_group_det.c_br_code=settle_mst.c_br_code1 and branch_group_det.n_cancel_flag = 0 ) 
			  else
				( select c_code from act_mst where act_mst.c_code = settle_mst.c_br_code1 and c_code >= (if 'BG0015' = 'zzz' then '000' else 'BG0015' endif ) and ( c_code <= 'BG0015' ) )
			  endif ) ) )  and settle_mst.c_cust_code in ('GC95','-PAYTM','GC93','GC94','ORDBUK')   
GROUP BY settle_mst.c_br_code1,   
         settle_mst.c_year1,   
         c_trans,   
         settle_mst.c_prefix1,   
         settle_mst.n_srno1,   
         settle_mst.c_cust_code,   
         act_mst_a.c_name,   
         act_mst_b.c_name,
			n_days,as_cust_cg,
            c_msme_no
  --HAVING ( sum(settle_mst.n_amount) <> 0 )    
 ) AS A
left outer join settle_mst_header
on ( A.c_br_code=settle_mst_header.c_br_code   ) and
		(   a.c_year1=settle_mst_header.c_year ) and   
	( a.c_prefix1= settle_mst_header.c_prefix  ) and   
	( a.n_srno1=settle_mst_header.n_srno  )     

			left outer join (select * 
								 from 	settle_mst 
								 where c_year+c_prefix+string(n_srno) <> c_year1+c_prefix1+string(n_srno1)) as settle_mst
								 on a.c_br_code = settle_mst.c_br_code1 and 
										a.c_year1 = settle_mst.c_year1 and 
										a.c_prefix1 = settle_mst.c_prefix1 and 
										a.n_srno1 = settle_mst.n_srno1 and 
										a.c_cust_code = settle_mst.c_cust_code   
			left outer join (select * 
								 from 	settle_mst 
								 where  c_year=c_year1 and c_prefix=c_prefix1 and n_srno=n_srno1) as Inv_amt
								 on a.c_br_code = Inv_amt.c_br_code1 and 
										a.c_year1 = Inv_amt.c_year1 and 
										a.c_prefix1 = Inv_amt.c_prefix1 and 
										a.n_srno1 = Inv_amt.n_srno1 and 
										a.c_cust_code = Inv_amt.c_cust_code   
										
 left outer join Cust_rec_mst  as supp_pay_mst on settle_mst.c_br_code = supp_pay_mst.c_br_code and 
										settle_mst.c_year = supp_pay_mst.c_year and 
										settle_mst.c_prefix = supp_pay_mst.c_prefix and 
										settle_mst.n_srno = supp_pay_mst.n_srno
										
left outer join jv_mst
on (   A.c_br_code=jv_mst.c_br_code ) and
		(  a.c_year1=jv_mst.c_year  ) and   
	(   a.c_prefix1=jv_mst.c_prefix ) and   
	(  a.n_srno1=jv_mst.n_srno  )  
	order by TRANNO

	select gin


