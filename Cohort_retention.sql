use portfolioProject;

--CLEANING DATA
--Total Record = 541909
--record with null customer ID=135080
--record with not null customer ID=406289
select * from [dbo].['Online Retail$'];

--total number of product they have
SELECT distinct Description from [dbo].['Online Retail$'] -- 4197 total product they have in their vault

Select * from [dbo].['Online Retail$']
Where CustomerID iS NULL;

-- creating CTE for the data with not null value for customerID 
;with Online_Retail as
(
Select * from [dbo].['Online Retail$']
Where CustomerID iS not  NULL
)

-- creating CTE for the data with not null value for customerID and positive Quantity and UnitPrice (397884 records)
,final_data as 
(
SELECT * from Online_Retail
WHERE Quantity>0 and UnitPrice>0
)
-- removed duplicate data (392,669 record) 
, final_dup_cleaned_data as
(Select *,ROW_NUMBER() over (partition by InvoiceNo,StockCode,Quantity order by InvoiceDate) as dup_flag 
from final_Data)
Select * 
into #Online_Retail_main -- creating a temp table for the final data
from final_dup_cleaned_data
where dup_flag=1


--CLEANED DATA 
SELECT * FROM #Online_Retail_main;

-- BEGIN COHORT ANALYSIS
-- for that we will be needing a 
--1.unique identifier (CustomerID)
--2.Initial Start Date
--3.Revanue Data

select
	CustomerID,
	min(InvoiceDate) first_purchase_date,
	DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) Cohort_Date
into #cohort
from #online_retail_main
group by CustomerID

SELECT * 
FROM #cohort
--WHAT IS COHORT 
--Group of people with similer characterstics

--What is Cohort Analysis
--analysis on several diffn cohort to get better understanding about their behaviour, pattern and trends

--what is cohort index
--number of months that has passed after the customer first engagement
Select mmm.*,
cohort_index=Year_diff*12+month_diff+1
into #cohort_retention
from
(
	Select mm.*,
		Year_diff=Invoice_year -Cohort_year,
		month_diff=Invoice_month-Cohort_month
		from
			(
			SELECT m.*,
			c.Cohort_Date,
			YEAR(InvoiceDate) Invoice_year,
			Month(InvoiceDate) Invoice_month,
			YEAR(Cohort_Date) Cohort_year,
			Month(Cohort_Date) Cohort_month

			FROM #online_retail_main m
			left Join #cohort c
			on m.CustomerID=c.CustomerID
			) mm
	)mmm

SELECT * FROM #cohort_retention

Select * 
into #cohort_pivot
From
(
Select distinct 
CustomerID,
Cohort_Date,
cohort_index
from #cohort_retention
--order by 1,3
) tbl

pivot(
count(CustomerID) 
for Cohort_index
	In
(
					[1], 
					[2], 
					[3], 
					[4], 
					[5], 
					[6], 
					[7],
					[8], 
					[9], 
					[10], 
					[11], 
					[12],
					[13])

)as pivot_table

Select * from #cohort_pivot
order by Cohort_Date

--Calculating cohort retention rate
select Cohort_Date ,
	(1.0 * [1]/[1] * 100) as [1], 
    1.0 * [2]/[1] * 100 as [2], 
    1.0 * [3]/[1] * 100 as [3],  
    1.0 * [4]/[1] * 100 as [4],  
    1.0 * [5]/[1] * 100 as [5], 
    1.0 * [6]/[1] * 100 as [6], 
    1.0 * [7]/[1] * 100 as [7], 
	1.0 * [8]/[1] * 100 as [8], 
    1.0 * [9]/[1] * 100 as [9], 
    1.0 * [10]/[1] * 100 as [10],   
    1.0 * [11]/[1] * 100 as [11],  
    1.0 * [12]/[1] * 100 as [12],  
	1.0 * [13]/[1] * 100 as [13]
from #cohort_pivot
order by Cohort_Date