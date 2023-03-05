--*****************************************************Question - 1 ******************************************************************

select A.profile_id AS 'Profiel ID', (A.first_name + ' ' + A.last_name ) AS 'FullName',A.phone AS 'Contact Number'
from 
	Tenant.dbo.Profiles A,
    Tenant.dbo.Tenancy_histories B
where 
    A.profile_id = B.profile_id
And B.move_out_date is not null
order by DATEDIFF(dd,B.move_out_date,B.move_in_date); 

--*****************************************************Question - 2 **************************************************************
Select  (first_name + ' ' + last_name ) AS 'Full Name', email as 'email id', phone 
from Tenant.dbo.Profiles 
where marital_status = 'Y'
And profile_id In ( select profile_id
     from Tenant.dbo.Tenancy_histories A
	 where rent > 9000);

--*****************************************************Question - 3 *************************************************************

Select A.profile_id, (A.first_name + ' ' + A.last_name ) AS 'Full Name', A.phone,A.email as 'email id',A.[city(hometown)], B.house_id, B.move_in_date,
B.move_out_date, B.rent,  
(select count(C.referral_valid) 
	   from Tenant.dbo.Referrals C
	   where C.[referrer_id(same as profile id)] = A.profile_id) as 'total number of referrals made',D.latest_employer, D.Occupational_category
from Tenant.dbo.Profiles A,
     Tenant.dbo.Tenancy_histories B,
	 Tenant.dbo.Employment_details D
where
      A.profile_id = B.profile_id
	  And B.profile_id = D.profile_id
      And A.[city(hometown)] in ('Bangalore', 'Pune') 
	  And B.move_in_date > '2014-12-31'
	  And B.move_out_date < '2016-02-01'
      order by B.rent desc;
  
	   
--************************************************** Question - 4 *********************************************************************

Select (A.first_name + ' ' + A.last_name) as 'full_name',A.email as 'email id', A.phone,A.referral_code, count(B.[referrer_id(same as profile id)]) as 'Count_of_referrals', 
Sum(B.referrer_bonus_amount) as 'Total_bonus'
from Tenant.dbo.Referrals B
	left join Tenant.dbo.Profiles A on A.profile_id = B.[referrer_id(same as profile id)]
	where B.referral_valid = 1
	group by A.profile_id,(A.first_name + ' ' + A.last_name),A.email, A.phone,A.referral_code
	having count(B.[referrer_id(same as profile id)])>1;

--***********************************************************Question - 5 *****************************************************************

Select coalesce([city(hometown)], 'Total'),
       Sum(B.rent) as 'City_tot'
from Tenant.dbo.Profiles A,
     Tenant.dbo.Tenancy_histories B
where 
     A.profile_id = B.profile_id
	 And A.[city(hometown)] in ('Bangalore', 'Delhi', 'Pune')
	 group by rollup (A.[city(hometown)]);
	 


--****************************************************************Question - 6 *****************************************************************
drop View vw_tenant

Create View vw_tenant
As
select A.profile_id, B.rent, b.move_in_date, C.house_type, C.Beds_vacant, D.description as 'Address', D.city 
from Tenant.dbo.Profiles A,
     Tenant.dbo.Tenancy_histories B,
	 Tenant.dbo.Houses C,
	 Tenant.dbo.Addresses D
	 where 
	 A.profile_id = B.profile_id
	 And B.house_id = C.house_id
	 And C.house_id = D.house_id
	 And B.move_in_date >= '2015-04-30'
	 And C.Beds_vacant > 0;

	 Select * from vw_tenant

--***************************************************************** Question - 7 *************************************************************
Select * from Tenant.dbo.Referrals;

update Tenant.dbo.Referrals
Set valid_till = DATEADD (mm,1,valid_till)
where [referrer_id(same as profile id)] in
(Select [referrer_id(same as profile id)]
  from  Tenant.dbo.Referrals 
  group by [referrer_id(same as profile id)]
  having count(*) > 2
 );

Select * from Tenant.dbo.Referrals;

--**************************************************************** Question - 8 ********************************************************
Select A.profile_id, (A.first_name + ' ' + A.last_name) as 'full_name', A.phone as 'Contact Number', 
IIF(B.rent > '10000', 'Grade A',
	IIF(B.rent < '7500', 'Grade C', 'Grade B')) as 'Customer Segment'
From Tenant.dbo.Profiles A,
     Tenant.dbo.Tenancy_histories B
	 where 
	 A.profile_id = B.profile_id;

-- *************************************************************** Question - 9 ***********************************************************
	 
Select (A.first_name + ' ' + A.last_name) as 'full_name', A.phone as 'Contact', A.[city(hometown)], D.* 
from Tenant.dbo.Profiles A
left join
	Tenant.dbo.Referrals B
	on A.profile_id = B.[referrer_id(same as profile id)]
inner join 
	Tenant.dbo.Tenancy_histories C
	on A.profile_id = C.profile_id
inner join 
	Tenant.dbo.Houses D
	on C.house_id = D.house_id
where B.[referrer_id(same as profile id)] is NULL;

-- ************************************************** Question - 10 ***********************************************************************

Select top 1 *
from Tenant.dbo.Houses
order by (bed_count - Beds_vacant) desc;

