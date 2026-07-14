/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

create or alter procedure silver.load_silver
as
	begin try 
		declare @start_time datetime , @end_time datetime , @batch_start_time datetime ,@batch_end_time datetime
		set @batch_start_time = getdate()
		print '========================================'
		print 'Loading Silver Layer'
		print '========================================'
		print '======================================================='
		print 'CRM Source Section'
		print '======================================================='
		print '>> Inserting Data into : silver.crm_cust_info'

		set @start_time = getdate()

		truncate table silver.crm_cust_info
		insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gender,
			cst_create_date
		)
		select 
		cst_id, 
		cst_key,
		-- removing unwanted spaces 
		trim(cst_firstname) as cst_firstname, 
		trim(cst_lastname) as cst_lastname,
		-- end of removing unwanted spaces 

		--Normalization/Standardalization
		case lower(trim(cst_marital_status))
			when 'm' then 'Married'
			when 's' then 'Single'
			else 'n/a' -- Handling missing values 
		end as cst_marital_status,
		case lower(trim(cst_gender))
			when 'm' then 'Male'
			when 'f' then 'Female'
			else 'n/a' -- Handling missing values 
		end as cst_gender,
		--End of Normalization/Standardalization

		--Dealing with duplicates Values in cst_id column by selecting the newest one
		cst_create_date
		from( 
			select * , 
			ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
		--End Dealing with duplicates Values in cst_column
		)as t 
		where flag_last = 1 and cst_id is not null -- guarantee that pk is the newest rows 

		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'

		print '--------------------------------------------------------'

		print '>> Inserting Data into : silver.crm_prd_info'

		set @start_time = getdate()

		truncate table silver.crm_prd_info
		insert into silver.crm_prd_info (
			prd_id, 
			prd_key,
			cat_id,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select 
		prd_id,
		substring(prd_key,7,LEN(prd_key)) as prd_key,
		replace(substring(prd_key,1,5),'-','_') as cat_id,
		prd_nm,
		isnull(prd_cost,0) as prd_cost,
		case upper(trim(prd_line))
			when 'M' then 'Mountain'
			when 'R' then 'Road'
			when 'S' then 'Other sales'
			when 'T' then 'Touring'
			else 'n/a'
		end as prd_line,
		cast (prd_start_dt as date) as prd_start_dt,
		cast (lead(DATEADD(DAY,-1,prd_start_dt)) over(partition by prd_key order by prd_start_dt) as date)as prd_end_dt
		from bronze.crm_prd_info

		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'

		print '--------------------------------------------------------'

		print '>> Inserting Data into : silver.crm_sales_details'

		set @start_time = getdate()

		insert into silver.crm_sales_details (
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quantity ,
			sls_price 
		)
		SELECT sls_ord_num
			  ,sls_prd_key
			  ,sls_cust_id
			  ,case 
				when sls_order_dt = 0 or len(sls_order_dt) != 8 then Null --handling invalid data
				else cast(cast (sls_order_dt as varchar) as date)
			  end as sls_order_dt
			  ,case 
				when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then Null
				else cast(cast (sls_ship_dt as varchar) as date)
			  end as sls_ship_dt
			  ,case 
				when sls_due_dt = 0 or len(sls_due_dt) != 8 then Null
				else cast(cast (sls_due_dt as varchar) as date)
			  end as sls_due_dt
			  ,case 
				when sls_sales is null or sls_sales <=0 or sls_sales <> abs(sls_price) * sls_quantity 
					then  abs(sls_price) * sls_quantity
				else sls_sales
			  end as sls_sales 
			  ,abs(sls_quantity) as sls_quantity
			  ,case 
				when sls_price is Null or sls_price <= 0 then sls_sales/Nullif(sls_quantity,0)
				else sls_price
			  end as sls_price
		FROM bronze.crm_sales_details

		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'

		print '======================================================='
		print 'ERP Source Section'
		print '======================================================='

		print '>> Inserting Data into : silver.erp_CUST_AZ12'

		set @start_time = getdate()

		truncate table silver.erp_CUST_AZ12
		insert into silver.erp_CUST_AZ12(
		CID,
		BDATE,
		GEN
		)
		select 
		case 
			when cid like 'NAS%' then SUBSTRING(cid,4,len(cid)) 
			else cid 
		end as CID,
		Case 
			when BDATE >= GETDATE() then Null
			else bdate 
		end as BDATE,
		case 
			when upper(trim(gen)) in ('F','FEMALE') then 'Female'
			when upper(trim(gen)) in ('M','MALE') then 'Male'
			else 'n/a'
		end as GEN
		from bronze.erp_CUST_AZ12

		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'

		print '--------------------------------------------------------'

		print '>> Inserting Data into : silver.erp_LOC_A101'

		set @start_time = getdate()
		truncate table silver.erp_LOC_A101
		insert into silver.erp_LOC_A101(
		CID,
		CNTRY
		)
		select 
		REPLACE(CID,'-','') as CID,
		case 
			when lower(trim(cntry)) = 'de' then 'Germany'
			when lower(trim(cntry)) in ('us','usa') then 'United States'
			when lower(trim(cntry)) is Null or lower(trim(cntry)) = '' then 'n/a'
			else trim(CNTRY)
		end as CNTRY
		from bronze.erp_LOC_A101

		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'
		print '--------------------------------------------------------'

		print '>> Inserting Data into : silver.erp_PX_CAT_G1V2'

		set @start_time = getdate()

		Truncate table silver.erp_PX_CAT_G1V2
		insert into silver.erp_PX_CAT_G1V2(
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		)
		SELECT ID
			,CAT
			,SUBCAT
			,MAINTENANCE
		FROM bronze.erp_PX_CAT_G1V2
		set @end_time = getdate()
		print 'Load duration : ' + cast(datediff(second,@start_time,@end_time)as nvarchar) + ' seconds'
		print '--------------------------------------------------------'

		set @batch_end_time = getdate()
		print'loading bronze layer completed'
		print 'Load Bronze layer duration : ' + cast(datediff(second,@batch_start_time,@batch_end_time) as nvarchar) + ' seconds'
		print'--------------------------------'
	end try
	begin catch
		print '============================'
		print 'Error ocurred during loading bronze layer'
		print 'Error Message' + error_message()
		print 'Error Number' + cast(error_number() as nvarchar)
		print 'Error Number' + cast(error_state() as nvarchar)
		print '============================'
	end catch
