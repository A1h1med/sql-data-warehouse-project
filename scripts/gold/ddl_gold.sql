/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

--Customer Dimension

if object_id('gold.dim_customer','v') is not null 
	drop view gold.dim_customer
create view gold.dim_customer
as 
	select  
	row_number() over(order by cst_id) as customer_key,
	cst_id as customer_id,
	cst_key as customer_number,
	cst_firstname as first_name,
	cst_lastname as last_name,
	case 
		when cst_gender != 'n/a' then cst_gender 
		else isnull(cst_gender,'n/a')
	end as gender , 
	CNTRY as country,
	cst_marital_status as marital_status,
	BDATE as birth_date,
	cst_create_date as create_date
	from silver.crm_cust_info CC
	left join 
	silver.erp_CUST_AZ12 EC
		on CC.cst_key = EC.CID
	left join silver.erp_LOC_A101 EL
		on CC.cst_key = EL.CID

--Product Dimension
if object_id('gold.dim_product','v') is not null 
	drop view gold.dim_product
alter view gold.dim_product
as 
	select 
	ROW_NUMBER() over(order by prd_start_dt,prd_key) as product_key,
	prd_id as product_id , 
	prd_key as product_number,
	prd_nm as product_name,
	cat as category , 
	subcat as subcategory, 
	MAINTENANCE,
	prd_cost as product_cost,
	prd_line as product_line,
	prd_start_dt as product_start_date
	from silver.crm_prd_info ci 
	left join 
	silver.erp_PX_CAT_G1V2 ec
		on ci.cat_id = ec.ID
	where prd_end_dt is null 

--Fact table 
if object_id('gold.fact_sales','v') is not null 
	drop view gold.fact_sales
create view gold.fact_sales
as 
	select 
	sls_ord_num as order_number,
	c.product_key,
	b.customer_key ,
	sls_order_dt as order_date,
	sls_ship_dt as ship_date,
	sls_due_dt as due_date,
	sls_sales sales_amount,
	sls_quantity as quantity,
	sls_price as price
	from silver.crm_sales_details a
	left join 
	gold.dim_customer b
		on a.sls_cust_id = b.customer_id
	left join 
	gold.dim_product c
		on a.sls_prd_key = c.product_number

