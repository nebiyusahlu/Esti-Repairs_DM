				
					 /* AUTO REPAIR COMPANY DATA KPIs */





-- KPI 1. Compare Referral growth by Referral Companies from 2016 ,2017 and 2018.

-- KPI 2. Total Sales Versus Target sales comparision by Month and Year.

-- KPI 3. Delivery status KPIs.

-- KPI 4. Repair order growth year over year

-- KPI 5. Total sales by territory KPI. 

-- KPI 6. Total sales by diffrenet catagories KPIs.





--=================================================================================================

/* 
	KPI 1.		THE NUMBER OF REFERRALS BY REFERRAL COMPANIES GROWTH YEAR OVER YEAR KPI
*/


	/*  POSITIVE INSIGHTS */

-- 1.  In 2018, 53 Referral companies Had a Positive Referral Growth Rate compared to 2017.  
-- 2.  There are 8 New Referral Companies that Referred Repair Orders in 2018 .


	/*  NEGATIVE INSIGHTS */

-- 1.  26 Referral Compaines had a Negative Growth rate compared to 2017
-- 2.  7 Referral comapines had a Flat growth Rate compared to 2017.

 /*  
	Note - Please Use the following query to check insight of the Growth of Referrals by Referral companies 2017 Vs 2018 

            SELECT *--COUNT(*)
			FROM vw_RefCompGrowthYrOverYr
			WHERE RefferalGrowthStatus ='PositiveGrowth'		
*/

CREATE VIEW vw_RefCompGrowthYrOverYr
AS
SELECT	  *,CASE  	
				WHEN YearlyGrowth2017vs2018 LIKE '-%.%' THEN 'NegativeGrowth'
				WHEN YearlyGrowth2017vs2018 =	  '100.00%'THEN 'DoubleGrowth' 
				WHEN YearlyGrowth2017vs2018 =     '0.00%' THEN 'NoDifference' 
				WHEN YearlyGrowth2017vs2018 =     'N/A' THEN 'NewRefferals'
			   	WHEN YearlyGrowth2017vs2018 >=    '1.00%' THEN 'PositiveGrowth'	
				WHEN YearlyGrowth2017vs2018 =     '1,800.00%' THEN 'MoreThanDoubleGrowth'	
				ELSE 'No Information'
			END AS RefferalGrowthStatus
FROM
(
SELECT		T1.Referral_company,ISNULL(CONVERT(VARCHAR(50),T3.Year2016),'N/A') Year2016,
			ISNULL(T3.NoOfRepairOrders2016,0) NoOfRepairOrders2016,
			ISNULL(CONVERT(VARCHAR(50),T2.Year2017), 'N/A') As Year2017,
			ISNULL(T2.NoOfRepairOrders2017,0) AS NoOfRepairOrders2017,
			T1.Year2018,T1.NoOfRepairOrders2018,
	   CASE WHEN T3.Year2016 IS NOT NULL THEN
			FORMAT(CONVERT(DECIMAL(10,0), (T2.NoOfRepairOrders2017 - T3.NoOfRepairOrders2016)) /
            CONVERT(DECIMAL(10,0), T3.NoOfRepairOrders2016), 'p')
			ELSE 'N/A' 
			END AS "YearlyGrowth2016vs2017",
	   CASE WHEN T2.Year2017 IS NOT NULL THEN
			FORMAT(CONVERT(DECIMAL(10,0), (T1.NoOfRepairOrders2018 - T2.NoOfRepairOrders2017)) /
            CONVERT(DECIMAL(10,0), T2.NoOfRepairOrders2017), 'p')
			ELSE 'N/A' 
			END AS "YearlyGrowth2017vs2018"
FROM
		(
		SELECT COUNT(DISTINCT R.Ro_Nbr)NoOfRepairOrders2018,RF.Referral_company,YEAR(R.DateIn) AS Year2018
		,SUM(COUNT( DISTINCT R.Ro_Nbr)) OVER( ORDER BY RF.Referral_company ) AS RunningTotalOfLate
		FROM Dim.RepairOrders R
		LEFT JOIN Fact.JobOrderCost F
		ON     R.RepairOrder_Key = F.RepairOrder_Key
		LEFT JOIN [Dim].[Referrals] RF
		ON     F.Referral_Key = RF.Referral_Key
		WHERE  YEAR(R.DateIn) = 2018
		GROUP BY RF.Referral_company,YEAR(DateIn)
		) T1
LEFT JOIN
		(
		SELECT COUNT( DISTINCT R.Ro_Nbr)NoOfRepairOrders2017,RF.Referral_company,YEAR(R.DateIn) AS Year2017
		,SUM(COUNT( DISTINCT R.Ro_Nbr)) OVER( ORDER BY RF.Referral_company ) AS RunningTotalOfLate
		FROM		Dim.RepairOrders R
		LEFT JOIN Fact.JobOrderCost F
		ON     R.RepairOrder_Key = F.RepairOrder_Key
		LEFT JOIN [Dim].[Referrals] RF
		ON     F.Referral_Key = RF.Referral_Key
		WHERE  YEAR(R.DateIn) = 2017
		GROUP BY RF.Referral_company,YEAR(DateIn)
		) T2
ON		T1.Referral_company = T2.Referral_company AND T2.Year2017 = T1.Year2018 - 1
LEFT JOIN
		(
		SELECT		COUNT( R.Ro_Nbr)NoOfRepairOrders2016,RF.Referral_company,YEAR(R.DateIn) AS Year2016
		,SUM(COUNT( DISTINCT R.Ro_Nbr)) OVER( ORDER BY RF.Referral_company ) AS RunningTotalOfLate
		FROM		Dim.RepairOrders R
		LEFT JOIN	Fact.JobOrderCost F
		ON			R.RepairOrder_Key = F.RepairOrder_Key
		LEFT JOIN	[Dim].[Referrals] RF
		ON			F.Referral_Key = RF.Referral_Key
		WHERE		YEAR(R.DateIn) = 2016
		GROUP BY	RF.Referral_company,YEAR(DateIn)
		) T3
ON			T2.Referral_company = T3.Referral_company AND T3.Year2016 = T2.Year2017 - 1
		) AS X





--====================================================================================


 /*		KPI 2. Total Sales Versus Target sales comparision by Month and Year	*/

/* 
	Stored procedure to see the number of repair orders, to calculate the percentage and amount of difference between TargetsalesGoal and
	Sales in that month and year by each Repair Shop. 
	Please Insert Parameters Month and Year to see the difference between TargetsalesGoal and Sales in that month and year

			Example - EXEC usp_TargetSalesVSalesByMthYr 'May','2017'
*/

CREATE PROC usp_TargetSalesVSalesByMthYr (@MonthOfYear VARCHAR(50),@DateInYear INT)
AS
BEGIN 
SET NOCOUNT ON 
SELECT		 ShopName,COUNT(DISTINCT b.Ro_Nbr) NumberOfOrders,DATENAME(MONTH,DateIn) MonthOfYear,
			 YEAR(DateIn) [Year],SUM(Cost)AS Sales,TargetSalesGoal,
			 FORMAT(CONVERT(DECIMAL(10,2),(SUM(Cost)/TargetSalesGoal)),'P') AS PercentageofTarget
FROM		 [Fact].[JobOrderCost] a
LEFT JOIN	 [Dim].[RepairOrders] b
ON			 a.RepairOrder_Key = b.RepairOrder_Key
LEFT JOIN	 [Dim].[Shop_Locations] SL
ON			 a.Shop_Key  = SL.Shop_Key
WHERE		 OrderCategoryType ='Total'
AND			 OrderCategory = 'Sales' 
AND			 ShopName <> 'Training' 
AND			 @MonthOfYear = DATENAME(MONTH,DateIn)  
AND			 @DateInYear =YEAR(DateIn)
GROUP BY	 YEAR(DateIn),MONTH(DateIn),TargetSalesGoal,ShopName,DATENAME(MONTH,DateIn)
ORDER BY	 ((SUM(Cost)/TargetSalesGoal) * 100)  DESC,YEAR(DateIn)DESC,MONTH(DateIn) DESC
END
 
/*
   KPI 3.  DELIVERY STATUS KPIs
*/

/*
POSITIVE INSIGHTS
*/

-- There Are a Total of 28.44 Percent 'Early' Auto Repairs Completions by all the shops

SELECT			COUNT(T2.NoRepairOrders) AS TotalRepairOrders,COUNT(T1.EarlyRepairOrders) AS EarlyRepairCompletions,
				FORMAT(CONVERT(DECIMAL(10,0),COUNT(T1.EarlyRepairOrders))/COUNT(T2.NoRepairOrders),'P') PercentageOfEarlyOrders
FROM			(
				SELECT		S.ShopName,R.Ro_Nbr,COUNT(DISTINCT R.Ro_Nbr)AS EarlyRepairOrders,R.DeliveryStatus,
							SUM(COUNT( DISTINCT R.Ro_Nbr)) OVER( ORDER BY S.ShopName ) AS RunningTtlOfErlyDeliveries
				FROM		Dim.RepairOrders R 
				LEFT JOIN	FACT.JobOrderCost F
				ON			F.RepairOrder_Key = R.RepairOrder_Key 
				LEFT JOIN   Dim.Shop_Locations S
				ON			F.Shop_Key = S.Shop_Key
				WHERE		R.DeliveryStatus = 'Early'
				GROUP BY	R.DeliveryStatus,S.ShopName,R.Ro_Nbr ) T1
RIGHT JOIN   
				(
				SELECT		( R.Ro_Nbr)AS NoRepairOrders,R.DeliveryStatus
				FROM		Dim.RepairOrders R 					
				) T2
ON				T1.Ro_Nbr = T2.NoRepairOrders


-- There Are 54.19 Percent 'OnTime' Auto Repairs Completions by all the shops

SELECT	COUNT(T2.NoRepairOrders) AS TotalRepairOrders,COUNT(T1.OnTimeRepairOrders) AS OnTimeRepairCompletions,
		FORMAT(CONVERT(DECIMAL(10,0),COUNT(T1.OnTimeRepairOrders))/COUNT(T2.NoRepairOrders),'P') AS PercentageOfOnTimeOrders
FROM			(
				SELECT          S.ShopName,Ro_Nbr,R.DeliveryStatus,COUNT(DISTINCT R.Ro_Nbr)AS OnTimeRepairOrders
				FROM			FACT.JobOrderCost F
				LEFT JOIN		Dim.RepairOrders R
				ON				F.RepairOrder_Key = R.RepairOrder_Key 
				LEFT JOIN		Dim.Shop_Locations S
				ON				F.Shop_Key = S.Shop_Key
				WHERE			R.DeliveryStatus = 'OnTime'
				GROUP BY		R.DeliveryStatus,S.ShopName,Ro_Nbr
				)T1
RIGHT JOIN   
				(
				SELECT		( R.Ro_Nbr)AS NoRepairOrders,R.DeliveryStatus
				FROM		Dim.RepairOrders R 					
				) T2
ON				T1.Ro_Nbr = T2.NoRepairOrders

/*
	NEGATIVE INSIGHTS 
*/
--   11.98 Percent of the Repairs were 'Late' repair completions by all the shops

SELECT	COUNT(T2.NoRepairOrders) AS TotalRepairOrders,COUNT(T1.LateRepairOrders) AS LateRepairOrders,
		FORMAT(CONVERT(DECIMAL(10,0),COUNT(T1.LateRepairOrders))/COUNT(T2.NoRepairOrders),'P') PercentageOfOnLate
FROM		(			
			SELECT			S.ShopName,Ro_Nbr,R.DeliveryStatus,COUNT( DISTINCT R.Ro_Nbr) AS LateRepairOrders								
			FROM			FACT.JobOrderCost F
			LEFT JOIN		Dim.RepairOrders R
			ON				F.RepairOrder_Key = R.RepairOrder_Key 
			LEFT JOIN		Dim.Shop_Locations S
			ON				F.Shop_Key = S.Shop_Key
			WHERE			R.DeliveryStatus = 'IsLate'
			GROUP BY		R.DeliveryStatus,S.ShopName,Ro_Nbr
			) T1
RIGHT JOIN   
			(
			SELECT		( R.Ro_Nbr)AS NoRepairOrders,R.DeliveryStatus
			FROM		Dim.RepairOrders R 					
			) T2
ON			T1.Ro_Nbr = T2.NoRepairOrders


-- 5.39 Percent of The Repair orders are 'InProcess' by diffrent shops

SELECT	COUNT(T2.NoRepairOrders) AS TotalRepairOrders,COUNT(T1.InProcessRepairOrders) AS InProcessRepairOrders,
		FORMAT(CONVERT(DECIMAL(10,0),COUNT(T1.InProcessRepairOrders))/COUNT(T2.NoRepairOrders),'P') PercentageInProcess
FROM			(
				SELECT		S.ShopName,Ro_Nbr,COUNT(DISTINCT R.Ro_Nbr)AS InProcessRepairOrders,R.DeliveryStatus
				FROM		Dim.RepairOrders R 
				LEFT JOIN	FACT.JobOrderCost F
				ON			F.RepairOrder_Key = R.RepairOrder_Key 
				LEFT JOIN   Dim.Shop_Locations S
				ON			F.Shop_Key = S.Shop_Key
				WHERE		R.DeliveryStatus = 'N/A'
				GROUP BY	R.DeliveryStatus,S.ShopName,Ro_Nbr
			) T1
RIGHT JOIN   
			(
			SELECT		( R.Ro_Nbr)AS NoRepairOrders,R.DeliveryStatus
			FROM		Dim.RepairOrders R 					
			) T2
ON			T1.Ro_Nbr = T2.NoRepairOrders

--==============================================================================

/* 

KPI 4. REPAIR ORDERS YEAR OVER YEAR GROWTH KPI

*/
   --- POSITIVE INSIGHT 

 -- We so a positive growth rate of repair orders from 2016 to 2017 to 2018
   
  --  0.14 Percent of Repair Orders were in 2016 

SELECT  COUNT(T1.Ro_Nbr) AS TotalRepairOrders,COUNT(T2.Ro_Nbr) NoOfRepairOrdersIn2016,
		FORMAT(CONVERT(DECIMAL(10,0),COUNT(T2.Ro_Nbr))/COUNT(T1.Ro_Nbr),'P') AS PercentageOfRepairs2016
FROM	   (
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)TotalNoOfOrders
				FROM		[Dim].[RepairOrders]
				GROUP BY	Ro_Nbr,YEAR(DateBooked)
			)T1
LEFT JOIN
			(
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)NoOfOrdersin2016
				FROM		[Dim].[RepairOrders]
				WHERE		YEAR(DateBooked) = 2016
				GROUP BY	Ro_Nbr,YEAR(DateBooked) 
			)T2
ON			 T1.Ro_Nbr = T2.Ro_Nbr			 


  -- 48.12 Percent of Repair Orders were In 2017
  

SELECT   COUNT(T1.Ro_Nbr) AS TotalRepairOrders,COUNT(T2.Ro_Nbr) AS NoOfRepairOrdersIn2017,
		 FORMAT(CONVERT(DECIMAL(10,0),COUNT(T2.Ro_Nbr))/COUNT(T1.Ro_Nbr),'P') AS PercentageOfOrderss2017
FROM	  (
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)TotalNoOfOrders
				FROM		[Dim].[RepairOrders]
				GROUP BY	Ro_Nbr,YEAR(DateBooked)
		  )T1
LEFT JOIN
		  (
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)NoOfOrdersin2016
				FROM		[Dim].[RepairOrders]
				WHERE		YEAR(DateBooked) = 2017
				GROUP BY	Ro_Nbr,YEAR(DateBooked) 
		   )T2
ON			T1.Ro_Nbr = T2.Ro_Nbr


  -- 51.74 Percent of Repair Orders were In 2018


SELECT  COUNT(T1.Ro_Nbr) AS TotalRepairOrders,COUNT(T2.Ro_Nbr) AS NoOfRepairOrdersIn2018,
		FORMAT(CONVERT(DECIMAL(10,0),COUNT(T2.Ro_Nbr))/COUNT(T1.Ro_Nbr),'P') PercentageOfOrders2018
FROM	   (
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)TotalNoOfOrders
				FROM		[Dim].[RepairOrders]
				GROUP BY	Ro_Nbr,YEAR(DateBooked)
			)T1
LEFT JOIN
			(
				SELECT		Ro_Nbr,YEAR(DateBooked)[Year],COUNT(*)NoOfOrdersin2016
				FROM		[Dim].[RepairOrders]
				WHERE		YEAR(DateBooked) = 2018
				GROUP BY	Ro_Nbr,YEAR(DateBooked) 
			)T2
ON			 T1.Ro_Nbr = T2.Ro_Nbr

--=========================================================================================
/*	

KPI 5.	 TOTAL SALES BY TERRITORY KPI 

*/


		/* CENTRAL TERRITORY */



--INSIGHT = 83.77 Percent of the total Sales was in 'Central Territory'

SELECT	SUM(T1.TotalCost) TotalSales,SUM(T2.TotalCost) CentralSales,
		FORMAT(CONVERT(DECIMAL(10,0),SUM(T2.TotalCost))/SUM(T1.TotalCost),'P') AS '%OfCentralSales'
FROM		(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				GROUP BY	[JobOrderCost_Key],TerritoryName
			)T1
LEFT JOIN
			(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				AND         SL.TerritoryName = 'Central'
				GROUP BY	[JobOrderCost_Key],TerritoryName
		   )T2
ON		    T1.[JobOrderCost_Key] = T2.JobOrderCost_Key	


		/*  TOTAL SALES IN SOUTH TERRITORY	*/

--INSIGHT = 7.28 Percent of the total Sales was in 'South Territory'

SELECT	SUM(T1.TotalCost) TotalSales,SUM(T2.TotalCost) SouthernSales,
		FORMAT(CONVERT(DECIMAL(10,0),SUM(T2.TotalCost))/SUM(T1.TotalCost),'P') AS '%OfSouthSales'
FROM		(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				GROUP BY	[JobOrderCost_Key],TerritoryName
			)T1
LEFT JOIN
			(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				AND         SL.TerritoryName = 'South'
				GROUP BY	[JobOrderCost_Key],TerritoryName
		   )T2
ON			T1.[JobOrderCost_Key] = T2.JobOrderCost_Key	
   

		/*  TOTAL SALES IN WESTERN TERRITORY	*/

--INSIGHT = 8.32 Percent of the total Sales was in 'Western Territory'

SELECT	SUM(T1.TotalCost) AS TotalSales,SUM(T2.TotalCost) AS WesternSales,
		FORMAT(CONVERT(DECIMAL(10,0),SUM(T2.TotalCost))/SUM(T1.TotalCost),'P') AS '%OfWesternSales'
FROM		(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				GROUP BY	[JobOrderCost_Key],TerritoryName

			)T1
LEFT JOIN
			(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) AS TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				AND         SL.TerritoryName = 'West'
				GROUP BY	[JobOrderCost_Key],TerritoryName
		   )T2
ON			T1.[JobOrderCost_Key] = T2.JobOrderCost_Key

		/*   TRAINING ONLY SALES	*/

--INSIGHT = 0.62 Percent of the Total Sales was in 'Training Only'

SELECT	SUM(T1.TotalCost) TotalSales,SUM(T2.TotalCost) TrainingSales,
		FORMAT(CONVERT(DECIMAL(10,0),SUM(T2.TotalCost))/SUM(T1.TotalCost),'P') AS '%OfTrainingSales'
FROM		(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				GROUP BY	[JobOrderCost_Key],TerritoryName

			)T1
LEFT JOIN
			(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				AND         SL.TerritoryName = 'Training Only'
				GROUP BY	[JobOrderCost_Key],TerritoryName
		   )T2
ON			T1.[JobOrderCost_Key] = T2.JobOrderCost_Key

	/*	TOTAL SALES IN SUPPORT CENTER */

--INSIGHT = Less than 1 Percent of the total Sales was in 'Support Center'

SELECT	SUM(T1.TotalCost) TotalSales,SUM(T2.TotalCost) CentralSales,
		FORMAT(CONVERT(DECIMAL(10,2),SUM(T2.TotalCost))/SUM(T1.TotalCost),'P') AS '%OFSupportSales'
FROM		(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				GROUP BY	[JobOrderCost_Key],TerritoryName
			)T1
LEFT JOIN
			(	
				SELECT		[JobOrderCost_Key],SL.TerritoryName,SUM(Cost) TotalCost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON          F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory ='Sales'
				AND         SL.TerritoryName = 'Support Center'
				GROUP BY	[JobOrderCost_Key],TerritoryName
		   )T2
ON			T1.[JobOrderCost_Key] = T2.JobOrderCost_Key


--=================================================================================


/* 

KPI 6. TOTAL SALES BY DIEFFRENT CATAGORIES 

*/

-- Total Sales of 'Paint' by Shop and Territory Insight


SELECT      T1.ShopName,T1.TerritoryName,(T1.Cost) AS PaintSalesByShop,
			FORMAT(CONVERT(DECIMAL(10,2),T1.COST)/SUM(F.Cost),'P') AS '%OfTotalPaintSales',
			SUM(T1.Cost)  OVER(ORDER BY T1.ShopName) AS RunningTotalOfPaintSales
FROM		[Fact].[JobOrderCost] F
LEFT JOIN	[Dim].[Shop_Locations] SL
ON			F.Shop_Key = SL.Shop_Key			
CROSS APPLY (	
				SELECT      F.Shop_Key,SL.ShopName,SL.TerritoryName,SUM(Cost) Cost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON			F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Paint'
				GROUP BY	F.Shop_Key,ShopName,SL.TerritoryName
			) T1
WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Paint'
GROUP BY	T1.Cost,T1.ShopName,T1.TerritoryName


--===========================================================

-- Total Sales of 'Mechanics' by Shop and Territory Insight 

SELECT      T1.ShopName,T1.TerritoryName,(T1.Cost) AS MechanicSalesByShop,
			FORMAT(CONVERT(DECIMAL(10,2),T1.COST)/SUM(F.Cost),'P') AS '%OfTotalMechanicSales',
			SUM(T1.Cost)  OVER(ORDER BY T1.ShopName) AS RunningTotalOfMechanicSales
FROM		[Fact].[JobOrderCost] F
LEFT JOIN	[Dim].[Shop_Locations] SL
ON			F.Shop_Key = SL.Shop_Key			
CROSS APPLY (	
				SELECT      F.Shop_Key,SL.ShopName,SL.TerritoryName,SUM(Cost) Cost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON			F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Mechanic'
				GROUP BY	F.Shop_Key,ShopName,SL.TerritoryName
			) T1
WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Mechanic'
GROUP BY	T1.Cost,T1.ShopName,T1.TerritoryName



--==================================================================


-- Total Sales of 'Body' by Shop and Territory Insight


SELECT      T1.ShopName,T1.TerritoryName,(T1.Cost) AS BodySalesByShop,
			FORMAT(CONVERT(DECIMAL(10,2),T1.COST)/SUM(F.Cost),'P') AS '%OfTotalBodySales',
			SUM(T1.Cost)  OVER(ORDER BY T1.ShopName) AS RunningTotalOfBodySales
FROM		[Fact].[JobOrderCost] F
LEFT JOIN	[Dim].[Shop_Locations] SL
ON			F.Shop_Key = SL.Shop_Key			
CROSS APPLY (	
				SELECT      F.Shop_Key,SL.ShopName,SL.TerritoryName,SUM(Cost) Cost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON			F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Body'
				GROUP BY	F.Shop_Key,ShopName,SL.TerritoryName
			) T1
WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Body'
GROUP BY	T1.Cost,T1.ShopName,T1.TerritoryName


--===========================================================


-- Total Sales of 'Detail' by Shop and Territory Insight


SELECT      T1.ShopName,T1.TerritoryName,(T1.Cost) AS DetailSalesByShop,
			FORMAT(CONVERT(DECIMAL(10,2),T1.COST)/SUM(F.Cost),'P') AS '%OfTotalDetailSales',
			SUM(T1.Cost)  OVER(ORDER BY T1.ShopName) AS RunningTotalOfDetailSales
FROM		[Fact].[JobOrderCost] F
LEFT JOIN	[Dim].[Shop_Locations] SL
ON			F.Shop_Key = SL.Shop_Key			
CROSS APPLY (	
				SELECT      F.Shop_Key,SL.ShopName,SL.TerritoryName,SUM(Cost) Cost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON			F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Detail'
				GROUP BY	F.Shop_Key,ShopName,SL.TerritoryName
			) T1
WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Detail'
GROUP BY	T1.Cost,T1.ShopName,T1.TerritoryName


--===========================================================


-- Total Sales of 'Electric' by Shop and Territory Insight


SELECT      T1.ShopName,T1.TerritoryName,(T1.Cost) AS ElectricSalesByShop,
			FORMAT(CONVERT(DECIMAL(10,2),T1.COST)/SUM(F.Cost),'P') AS '%OfTotalElectricSales',
			SUM(T1.Cost)  OVER(ORDER BY T1.ShopName) AS RunningTotalOfElectricSales
FROM		[Fact].[JobOrderCost] F
LEFT JOIN	[Dim].[Shop_Locations] SL
ON			F.Shop_Key = SL.Shop_Key			
CROSS APPLY (	
				SELECT      F.Shop_Key,SL.ShopName,SL.TerritoryName,SUM(Cost) Cost
				FROM		[Fact].[JobOrderCost] F
				LEFT JOIN	[Dim].[Shop_Locations] SL
				ON			F.Shop_Key = SL.Shop_Key
				WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Electric'
				GROUP BY	F.Shop_Key,ShopName,SL.TerritoryName
			) T1
WHERE		OrderCategoryType = 'Total' AND OrderCategory = 'Electric'
GROUP BY	T1.Cost,T1.ShopName,T1.TerritoryName

--===========================================================


/* NUMBER OF TOTAL LOSSES BY SHOP AND TERRITORY KPI */

-- INSIGHT = Percentage of Total Loss by Shop,Territory,Region and City KPI



SELECT   T3.ShopName,T3.TerritoryName,T3.City,T3.RegionName,COUNT(T2.TotalLoss) AS TotalLossPerShop,
		 TotalNoOfTotalLoses,
		 FORMAT(CONVERT(DECIMAL(10,2),COUNT(T2.TotalLoss))/ T4.TotalNoOfTotalLoses,'P')  AS '%OfTotalLoss'
FROM		(
			SELECT		RepairOrder_Key, Shop_Key,Order_Number,COUNT(DISTINCT Order_Number) NUM
			FROM		FACT.JobOrderCost
			GROUP   BY Order_Number,Shop_Key,RepairOrder_Key
			) T1
LEFT JOIN
			( 
			SELECT		Ro_Nbr,TotalLoss
			FROM		[Dim].[RepairOrders]
			WHERE       TotalLoss = 1
			) T2
ON			T1.Order_Number = T2.Ro_Nbr
LEFT  JOIN 
			(
			SELECT Shop_Key,ShopName,TerritoryName,RegionName,City
			FROM	[Dim].[Shop_Locations] 
			)T3
ON			T1.Shop_Key = T3.Shop_Key
CROSS APPLY 	
			(		
			SELECT COUNT(TotalLoss) TotalNoOfTotalLoses
			FROM	[Dim].[RepairOrders] 
			WHERE		TotalLoss = 1
			) T4
GROUP BY T3.ShopName,T3.TerritoryName,T3.City,T3.RegionName,T4.TotalNoOfTotalLoses
ORDER BY '%OfTotalLoss' DESC



--===================================================================

/* ALL THE STATUSES OF  REPAIR ORDERS  BY EACH OF THE 78 SHOPS INSIGHT */

--  Repair Orders 'Delivered' Percentage by Repair Shop

-- Positive Insight = 22 of the Shops Delivered more than 75 percent of the Repair Orders


SELECT  T1.ShopName,T1.NoOfOrders,T2.NoOfDelivered,
		FORMAT(CONVERT(DECIMAL (10,2),T2.NoOfDelivered)/T1.NoOfOrders,'P') AS '%OfDeliveredOrders'
FROM     (SELECT COUNT(DISTINCT F.Order_Number) AS NoOfOrders,(SL.ShopName) AS ShopName
		  FROM	 [Fact].[JobOrderCost] F
		  LEFT JOIN	Dim.Shop_Locations SL
		  ON			F.Shop_Key = SL.Shop_Key
		  GROUP BY	SL.ShopName
		  ) T1
LEFT JOIN
		(
		SELECT  COUNT(DISTINCT F.Order_Number) AS NoOfDelivered,(SL.ShopName) AS ShopName
		FROM		[Fact].[JobOrderCost] F
		LEFT JOIN	Dim.Status S
		ON			F.Status_Key = S.Status_Key
		LEFT JOIN  DIM.Shop_Locations SL
		ON			F.Shop_Key = SL.Shop_Key
		WHERE		S.StatusDescription = 'Delivered'
		GROUP BY SL.ShopName
		) T2
ON	T1.ShopName = T2.ShopName
GROUP BY T1.ShopName,T1.NoOfOrders,T2.NoOfDelivered
ORDER BY '%OfDeliveredOrders' DESC

--==========================================================

/* REPAIR ORDERS WITH 'Possible Total Loss' INSIGHT */

--  Number and Percentage of Repair orders that are 'Possible Total Losses' in each Shop

SELECT  T1.ShopName,T1.NoOfOrders,ISNULL(T2.NoOfPossibleTotalLoss,0) AS NoOfPossibleTotalLoss,
		ISNULL(FORMAT(CONVERT(DECIMAL (10,2),T2.NoOfPossibleTotalLoss)/T1.NoOfOrders,'P'),'0%' )AS '%OfPossibleTotalLoss'
FROM        (
			  SELECT COUNT(DISTINCT F.Order_Number) AS NoOfOrders,(SL.ShopName) AS ShopName
			  FROM	 [Fact].[JobOrderCost] F
			  LEFT JOIN	Dim.Shop_Locations SL
			  ON			F.Shop_Key = SL.Shop_Key
			  GROUP BY	SL.ShopName
			) T1
LEFT JOIN
			(
			SELECT  COUNT(DISTINCT F.Order_Number) AS NoOfPossibleTotalLoss,(SL.ShopName) AS ShopName
			FROM		[Fact].[JobOrderCost] F
			LEFT JOIN	Dim.Status S
			ON			F.Status_Key = S.Status_Key
			LEFT JOIN  DIM.Shop_Locations SL
			ON			F.Shop_Key = SL.Shop_Key
			WHERE		S.StatusDescription = 'Possible Total Loss'
			GROUP BY SL.ShopName
			) T2
ON		 T1.ShopName = T2.ShopName
GROUP BY T1.ShopName,T1.NoOfOrders,T2.NoOfPossibleTotalLoss
ORDER BY '%OfPossibleTotalLoss' DESC

--========================================================


/* Total Cost, Number and Percentage of Towed Repair Orders by Shop Insight */


SELECT	T1.ShopName,T2.TotalRepairOrders,T1.TowedRepairOrders,
		FORMAT(CONVERT(DECIMAL(10,2),T1.TowedRepairOrders)/T2.TotalRepairOrders,'P') '%OfTowedRepairOrders',T1.CostOfTowing
FROM		(
		SELECT		(SL.ShopName) AS ShopName,COUNT(DISTINCT F.ORDER_NUMBER) As TowedRepairOrders,
					SUM(F.Cost) AS CostOfTowing
		FROM		FACT.JobOrderCost F
		LEFT JOIN	DIM.RepairOrders R
		ON			F.RepairOrder_Key = R.RepairOrder_Key
		LEFT JOIN	DIM.Shop_Locations SL
		ON			F.Shop_Key = SL.Shop_Key
		WHERE		[OrderCategoryType] = 'Total' AND [OrderCategory] = 'Towing' AND R.TowIn = 1
		GROUP BY	SL.ShopName
			) T1
LEFT JOIN
			(
		 SELECT		(SL.ShopName) AS ShopName,COUNT(DISTINCT F.Order_Number) TotalRepairOrders
		 FROM		FACT.JobOrderCost F
		 LEFT JOIN	Dim.Shop_Locations SL
		 ON			F.Shop_Key = SL.Shop_Key
		 GROUP BY	SL.ShopName
			) T2

ON		  T1.ShopName = T2.ShopName
ORDER BY '%OfTowedRepairOrders' DESC

--================================================

-- COST OF RENTALS BY SHOP

SELECT	T1.ShopName,T2.TotalRepairOrders,T1.NoOfRentals,
		FORMAT(CONVERT(DECIMAL(10,2),T1.NoOfRentals)/T2.TotalRepairOrders,'P') '%OfRentals',T1.CostOfRentals
FROM		(
		SELECT		(SL.ShopName) AS ShopName,COUNT(DISTINCT F.ORDER_NUMBER) As NoOfRentals,
					SUM(F.Cost) AS CostOfRentals
		FROM		FACT.JobOrderCost F
		LEFT JOIN	DIM.RepairOrders R
		ON			F.RepairOrder_Key = R.RepairOrder_Key
		LEFT JOIN	DIM.Shop_Locations SL
		ON			F.Shop_Key = SL.Shop_Key
		WHERE		[OrderCategoryType] = 'Total' AND [OrderCategory] = 'Rental' AND R.Rental = 1
		GROUP BY	SL.ShopName
			) T1
LEFT JOIN
			(
		 SELECT		(SL.ShopName) AS ShopName,COUNT(DISTINCT F.Order_Number) TotalRepairOrders
		 FROM		FACT.JobOrderCost F
		 LEFT JOIN	Dim.Shop_Locations SL
		 ON			F.Shop_Key = SL.Shop_Key
		 GROUP BY	SL.ShopName
			) T2

ON		  T1.ShopName = T2.ShopName
ORDER BY '%OfRentals' DESC





--###########################################################################################################
