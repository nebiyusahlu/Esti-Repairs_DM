USE [EstimatesDM]
GO

/****** Object:  StoredProcedure [dbo].[usp_LoadEstimateDataDW]    Script Date: 4/7/2021 5:53:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[usp_LoadEstimateDataDW]
AS 
BEGIN 

SET NOCOUNT ON



IF NOT EXISTS (
SELECT  schema_name
FROM    information_schema.schemata
WHERE   schema_name = 'Fact' ) 

BEGIN
EXEC sp_executesql N'CREATE SCHEMA Fact'
END

IF NOT EXISTS (
SELECT  schema_name
FROM    information_schema.schemata
WHERE   schema_name = 'Dim' ) 

BEGIN
EXEC sp_executesql N'CREATE SCHEMA Dim'
END

IF OBJECT_ID('tempdb..#JobCost_UnPivot') IS NOT NULL DROP TABLE #JobCost_UnPivot

SELECT  ro_nbr, ChargeType,
	CASE 
		WHEN ChargeType LIKE '%units%' THEN 'Units'
		WHEN ChargeType LIKE '%total%' THEN 'Total'
		WHEN ChargeType LIKE '%disc%' THEN 'Discount'
		WHEN ChargeType LIKE '%tax%' THEN 'Tax'		
		WHEN ChargeType LIKE '%cap%' THEN 'Cap'			
	END	CategoryType,
	CASE 
		WHEN ChargeType LIKE '%paint' THEN 'Paint'
		WHEN ChargeType LIKE '%frame' THEN 'Frame'
		WHEN ChargeType LIKE '%mech' THEN 'Mechanic'		
		WHEN ChargeType LIKE '%elec' THEN 'Electric'
		WHEN ChargeType LIKE '%detail' THEN 'Detail'	
		WHEN ChargeType LIKE '%glass_lbr' THEN 'Glass Labor'
		WHEN ChargeType LIKE '%glass_parts' THEN 'Glass Parts'						
		WHEN ChargeType LIKE '%glass' THEN 'Glass'
		WHEN ChargeType LIKE '%aftermarket' THEN 'After Market'		
		WHEN ChargeType LIKE '%lkq' THEN 'Like Kind Quality'		
		WHEN ChargeType LIKE '%oem' THEN 'Original Equipment Manufacturer'
		WHEN ChargeType LIKE '%pmatl' THEN 'pmatl'		
		WHEN ChargeType LIKE '%bmatl' THEN 'bmatl'		
		WHEN ChargeType LIKE '%sublet' THEN 'Sublet'			
		WHEN ChargeType LIKE '%Towing' THEN 'Towing'		
		WHEN ChargeType LIKE '%hazwaste' THEN 'Hazard Waste'		
		WHEN ChargeType LIKE '%rental' THEN 'Rental'			
		WHEN ChargeType LIKE '%body' THEN 'Body'		
		WHEN ChargeType LIKE '%storage' THEN 'Storage'				
		WHEN ChargeType LIKE '%sales' THEN 'Sales'
		WHEN ChargeType LIKE '%disc' THEN 'Discount'
		WHEN ChargeType LIKE '%tax' THEN 'Tax'		
	 END	Category,
	 Orders AS Cost
INTO #JobCost_UnPivot 
FROM   
	(SELECT		ro_nbr,	CONVERT(DECIMAL(10,2),act_units_body)act_units_body,
				CONVERT(DECIMAL(10,2),act_units_paint)act_units_paint, 
				CONVERT(DECIMAL(10,2),act_units_frame)act_units_frame, 
				CONVERT(DECIMAL(10,2),act_units_mech)act_units_mech, 
				CONVERT(DECIMAL(10,2),act_units_elec)act_units_elec, 
				CONVERT(DECIMAL(10,2),act_units_glass)act_units_glass, 
				CONVERT(DECIMAL(10,2),act_units_detail)act_units_detail, 
				CONVERT(DECIMAL(10,2),total_body)total_body, 
				CONVERT(DECIMAL(10,2),total_paint)total_paint, 
				CONVERT(DECIMAL(10,2),total_frame)total_frame, 
				CONVERT(DECIMAL(10,2),total_mech)total_mech, 
				CONVERT(DECIMAL(10,2),total_elec)total_elec, 
				CONVERT(DECIMAL(10,2),total_glass_lbr)total_glass_lbr, 
				CONVERT(DECIMAL(10,2),total_detail)total_detail, 
				CONVERT(DECIMAL(10,2),total_oem)total_oem, 
				CONVERT(DECIMAL(10,2),total_aftermarket)total_aftermarket, 
				CONVERT(DECIMAL(10,2),total_lkq)total_lkq, 
				CONVERT(DECIMAL(10,2),total_glass_parts)total_glass_parts, 
				CONVERT(DECIMAL(10,2),total_pmatl)total_pmatl, 
				CONVERT(DECIMAL(10,2),total_bmatl)total_bmatl, 
				CONVERT(DECIMAL(10,2),total_sublet)total_sublet, 
				CONVERT(DECIMAL(10,2),total_towing)total_towing, 
				CONVERT(DECIMAL(10,2),total_hazwaste)total_hazwaste, 
				CONVERT(DECIMAL(10,2),total_rental)total_rental, 
				CONVERT(DECIMAL(10,2),total_storage)total_storage, 
				CONVERT(DECIMAL(10,2),disc_body)disc_body, 
				CONVERT(DECIMAL(10,2),disc_paint)disc_paint, 
				CONVERT(DECIMAL(10,2),disc_frame)disc_frame, 
				CONVERT(DECIMAL(10,2),disc_mech)disc_mech, 
				CONVERT(DECIMAL(10,2),disc_elec)disc_elec, 
				CONVERT(DECIMAL(10,2),disc_glass_lbr)disc_glass_lbr,
				CONVERT(DECIMAL(10,2),disc_detail)disc_detail, 
				CONVERT(DECIMAL(10,2),disc_oem)disc_oem, 
				CONVERT(DECIMAL(10,2),disc_aftermarket)disc_aftermarket, 
				CONVERT(DECIMAL(10,2),disc_lkq)disc_lkq, 
				CONVERT(DECIMAL(10,2),disc_glass_parts)disc_glass_parts, 
				CONVERT(DECIMAL(10,2),disc_pmatl)disc_pmatl, 
				CONVERT(DECIMAL(10,2),disc_bmatl)disc_bmatl,											
				CONVERT(DECIMAL(10,2),disc_sublet)disc_sublet, 
				CONVERT(DECIMAL(10,2),disc_towing)disc_towing, 
				CONVERT(DECIMAL(10,2),disc_hazwaste)disc_hazwaste, 
				CONVERT(DECIMAL(10,2),disc_rental)disc_rental, 
				CONVERT(DECIMAL(10,2),disc_storage)disc_storage, 
				CONVERT(DECIMAL(10,2),cap_pmatl)cap_pmatl, 
				CONVERT(DECIMAL(10,2),tax_body)tax_body, 
				CONVERT(DECIMAL(10,2),tax_paint)tax_paint, 
				CONVERT(DECIMAL(10,2),tax_frame)tax_frame, 
				CONVERT(DECIMAL(10,2),tax_mech)tax_mech, 
				CONVERT(DECIMAL(10,2),tax_elec)tax_elec, 
				CONVERT(DECIMAL(10,2),tax_glass_lbr)tax_glass_lbr, 
				CONVERT(DECIMAL(10,2),tax_detail)tax_detail, 
				CONVERT(DECIMAL(10,2),tax_oem)tax_oem, 
				CONVERT(DECIMAL(10,2),tax_aftermarket)tax_aftermarket, 
				CONVERT(DECIMAL(10,2),tax_lkq)tax_lkq, 
				CONVERT(DECIMAL(10,2),tax_glass_parts)tax_glass_parts, 
				CONVERT(DECIMAL(10,2),tax_pmatl)tax_pmatl, 
				CONVERT(DECIMAL(10,2),tax_bmatl)tax_bmatl, 
				CONVERT(DECIMAL(10,2),tax_sublet)tax_sublet, 
				CONVERT(DECIMAL(10,2),tax_towing)tax_towing, 
				CONVERT(DECIMAL(10,2),tax_hazwaste)tax_hazwaste, 
				CONVERT(DECIMAL(10,2),tax_rental)tax_rental, 
				CONVERT(DECIMAL(10,2),tax_storage)tax_storage, 
				CONVERT(DECIMAL(10,2),total_sales)total_sales, 
				CONVERT(DECIMAL(10,2),total_tax)total_tax, 
				CONVERT(DECIMAL(10,2),total_disc)total_disc
FROM		[Estimates].dbo.tblRojobcost) AS p  
UNPIVOT  
		   ( Orders FOR ChargeType IN   
				(	act_units_body,act_units_paint, act_units_frame, act_units_mech,act_units_elec, 
					act_units_glass,act_units_detail,total_body, total_paint, total_frame,total_mech, 
					total_elec,total_glass_lbr, total_detail, total_oem, total_aftermarket, total_lkq, 
					total_glass_parts,total_sublet, total_towing, total_hazwaste, total_rental, total_storage,
					total_pmatl,total_bmatl,disc_body, disc_paint, disc_frame, disc_mech,disc_elec,disc_glass_lbr, 
					disc_detail,disc_oem, disc_aftermarket, disc_lkq, disc_glass_parts,disc_sublet, disc_towing, 
					disc_hazwaste,disc_rental, disc_storage, tax_body,tax_paint, tax_frame,tax_mech, tax_pmatl, 
					tax_bmatl,tax_elec, tax_glass_lbr,tax_detail, tax_oem, tax_aftermarket,tax_lkq, tax_glass_parts, 
					tax_sublet,tax_towing, tax_hazwaste, tax_rental, tax_storage,total_sales,total_tax,total_disc)  
				)AS unpvt; 





IF OBJECT_ID('tempdb..#FullDenormalizedTable') IS NOT NULL DROP TABLE #FullDenormalizedTable



SELECT  A.RO_NBR, DateCreated AS DateBooked, DateIn, CONVERT(varchar, DateIn ,112) AS DateIn_Style_112, 
		[DateStarted], [DatePromised],[DateCompleted] ,[DateOut] ,[DateClosed], TotalLoss, NoShow, Released, 
		Abandoned, Driveable, TowIn,TowRefer,TowTransfer, Rental, TearDown, OutOfCompliance,
		DATEDIFF(DAY, DatePromised, DateCompleted) AS [DaysLate], 
CASE 
		WHEN DATEDIFF(DAY, DatePromised, DateCompleted) > 0 THEN 'IsLate'
		WHEN DATEDIFF(DAY, DatePromised, DateCompleted)  between -1 and 0 THEN 'OnTime'
		WHEN DATEDIFF(DAY, DatePromised, DateCompleted)  < -1 THEN 'Early'
		ELSE 'N/A'
		END AS DeliveryStatus, 
		B.RefSourceID, B.ref_company,(BusinessUnitID) AS ShopID,F.RegionID,A.ShopNumber, DBA As ShopName,
		C.OptimumInProcess, c.MaxInProcess, C.TargetSalesGoal,C.City, C.State,C.Zip,F.Description AS RegionName,
		SC.CategoryKey,CategoryName,H.MarketDescription AS Market,G.TerritoryName,
		E.StatusID, E.StatusDesc,E.Active,CategoryType,Category,ChargeType,Cost 

INTO	#FullDenormalizedTable 
FROM [Estimates].dbo.tblRepairOrders AS A
LEFT JOIN [Estimates].dbo.tblReferralSources AS B
ON A.RefSourceID = B.RefSourceID
LEFT JOIN [Estimates].dbo.tblBusinessUnits AS C
ON A.ShopNumber = C.BusinessUnitID
LEFT JOIN [Estimates].dbo.tblRojobcost AS D
ON A.RO_NBR = D.ro_nbr
LEFT JOIN [Estimates].dbo.tblStatusCodes AS E
ON A.StatusID = E.StatusID
LEFT JOIN   [Estimates].[dbo].[StatusCategory] SC
ON	E.CategoryKey = SC.CategoryKey
LEFT JOIN [Estimates].dbo.tblBusinessUnitRegions AS F
ON C.RegionID = F.RegionID
LEFT JOIN [Estimates].dbo.tblBusinessUnitTerritories AS G
ON C.TerritoryID = G.TerritoryID
LEFT JOIN [Estimates].dbo.tblBusinessUnitMarkets AS H
ON C.MarketID = H.MarketID
LEFT JOIN #JobCost_UnPivot AS I 
ON I.RO_NBR = A.RO_NBR

/* 
SELECT *
FROM    #FullDenormalizedTable 
*/
------------------------------------------------------END OF VIEW #FullDenormalizedTable


IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Dim.Shop_Locations' and xtype='U') 

BEGIN



CREATE TABLE Dim.Shop_Locations
						 (Shop_Key INT PRIMARY KEY IDENTITY(1,1),ShopID INT,
						  ShopName NVARCHAR(50),TerritoryName NVARCHAR(50),MarketName NVARCHAR(50),RegionName NVARCHAR(50),
						  [State] NVARCHAR(50),City NVARCHAR(50),Zip NVARCHAR(50),
						  OptimumInProcess NUMERIC(18,0),
						  MaxInProcess NUMERIC(18,0),TargetSalesGoal NUMERIC(18,0),Shops_CheckSum INT) 

END
-----------------------------MERGE Dim.Shop_Locations

MERGE Dim.Shop_Locations AS TARGET
USING			(   
				SELECT DISTINCT  ShopID,ShopName,TerritoryName,Market,
								 RegionName,[State],City,Zip,
							     OptimumInProcess,MaxInProcess,TargetSalesGoal,
								 BINARY_CHECKSUM(ShopName) Shops_CheckSum 			
			    FROM			 #FullDenormalizedTable F
				) AS SOURCE
ON				TARGET.ShopID = SOURCE.ShopID

WHEN MATCHED AND TARGET.Shops_CheckSum <> SOURCE.Shops_CheckSum
THEN
			UPDATE
			SET				
							TARGET.ShopID = SOURCE.ShopID,
							TARGET.ShopName = SOURCE.ShopName,
							TARGET.OptimumInProcess = SOURCE.OptimumInProcess,
							TARGET.MaxInProcess= SOURCE.MaxInProcess,
							TARGET.TargetSalesGoal= SOURCE.TargetSalesGoal
WHEN NOT MATCHED 
THEN
			INSERT			(
							 ShopID,ShopName,TerritoryName,MarketName,RegionName,
							 State,City,Zip,OptimumInProcess,MaxInProcess,
							 TargetSalesGoal,shops_CheckSum)

			VALUES			(
							 SOURCE.ShopID,SOURCE.ShopName,SOURCE.TerritoryName,SOURCE.Market,
							 SOURCE.RegionName,SOURCE.State,SOURCE.City,SOURCE.Zip,
							 SOURCE.OptimumInProcess,SOURCE.MaxInProcess,SOURCE.TargetSalesGoal,
							 SOURCE.Shops_CheckSum
							 );

/*
SELECT *
FROM   Dim.Shop_Locations
*/								 
--==============================================================END OF Dim.BusinessUnits

IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Dim.RepairOrders' and xtype='U') 

BEGIN

	CREATE TABLE Dim.RepairOrders
	(
	 RepairOrder_Key INT PRIMARY KEY IDENTITY (1,1), 
	 Ro_Nbr INT, 
	 DateBooked Datetime,
	 DateIn Date,
	 DateIn_Style_112 Varchar(50), 
	 DateStarted Date,
	 DatePromised Date,
	 DateCompleted Date,
	 DateOut Date,
	 DateClosed Date,
	 DaysLate INT,  
	 DeliveryStatus Varchar(50), 
	 TotalLoss Bit,
	 NoShow Bit,
	 Released Bit,
	 Abandoned Bit,
	 Driveable Bit,
	 TowIn Bit,
	 TowRefer Bit,
	 TowTransfer Bit,
	 Rental Bit,
	 TearDown Bit,
	 OutOfCompliance Bit,
	 RepairOrder_CheckSum INT
	)	      
	

END

------------------------------------MERGER RepairOrders

MERGE		Dim.RepairOrders AS TARGET
USING		(	
			 SELECT	DISTINCT    RO_NBR, DateBooked, DateIn, DateIn_Style_112,DateStarted,DatePromised,
								DateCompleted,DateOut,DateClosed,DaysLate,DeliveryStatus,TotalLoss, NoShow, Released, Abandoned, 
								Driveable, TowIn,TowRefer, TowTransfer, Rental, TearDown, OutOfCompliance,
								BINARY_CHECKSUM(RO_NBR) RepairOrder_CheckSum
			 FROM		   #FullDenormalizedTable 	
			)AS SOURCE
ON			TARGET.Ro_Nbr = SOURCE.RO_NBR

WHEN	MATCHED and  TARGET.RepairOrder_CheckSum <> SOURCE.RepairOrder_CheckSum
THEN		
			UPDATE
			SET		TARGET.RO_NBR = SOURCE.RO_NBR

					
WHEN	NOT MATCHED
THEN		
			INSERT			(
							 RO_NBR, DateBooked, DateIn, DateIn_Style_112,DateStarted, DatePromised,
							 DateCompleted,DateOut ,DateClosed,DaysLate,DeliveryStatus, TotalLoss, NoShow, 
							 Released, Abandoned,Driveable,TowIn,TowRefer, TowTransfer, Rental, TearDown, OutOfCompliance,
							 RepairOrder_CheckSum
							)
			VALUES		    (
							 SOURCE.RO_NBR, SOURCE.DateBooked, SOURCE.DateIn, SOURCE.DateIn_Style_112, 
							 SOURCE.DateStarted, SOURCE.DatePromised,SOURCE.DateCompleted,SOURCE.DateOut,
							 SOURCE.DateClosed,SOURCE.DaysLate,SOURCE.DeliveryStatus, SOURCE.TotalLoss, 
							 SOURCE.NoShow, SOURCE.Released,SOURCE.Abandoned, SOURCE.Driveable, SOURCE.TowIn, 
							 SOURCE.TowRefer,SOURCE.TowTransfer,SOURCE.Rental,SOURCE.TearDown,SOURCE.OutOfCompliance, 
							 SOURCE.RepairOrder_CheckSum
							);
/*
SELECT *
FROM Dim.RepairOrders
*/
--===============================================================--END OF Dim.RepairOrders

IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Dim.Category' and xtype='U') 

BEGIN

CREATE TABLE Dim.Category
						(  Category_Key INT PRIMARY KEY IDENTITY(1,1), CategoryID INT , CategoryName Varchar(50),
						   Catagory_CheckSum INT)
END

--------------------------------MERGE DIm.Catagory

MERGE Dim.Category AS TARGET
		USING		( 
					SELECT DISTINCT CategoryKey,CategoryName,
									BINARY_CHECKSUM(CategoryName) Catagory_CheckSum
					FROM			#FullDenormalizedTable
					) AS SOURCE
ON					TARGET.CategoryID = SOURCE.CategoryKey

WHEN	MATCHED AND TARGET.Catagory_CheckSum <> SOURCE.Catagory_CheckSum
THEN 
			UPDATE
			SET              TARGET.CategoryName = SOURCE.CategoryName
WHEN	NOT MATCHED
THEN 
			INSERT          (
							  CategoryID,CategoryName,Catagory_CheckSum
							)
			VALUES          (
							  SOURCE.CategoryKey,SOURCE.CategoryName,SOURCE.Catagory_CheckSum
							);

/* 
SELECT *
FROM Dim.Category
*/

--===================================================================--END OF DIM.CATAGORY



IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Dim.Referrals' and xtype='U') 

BEGIN

CREATE TABLE Dim.Referrals
						( Referral_Key INT PRIMARY KEY IDENTITY(1,1),ReferralSourceID INT, Referral_company NVARCHAR(50),
						  Referral_CheckSum INT)
END
----------------------------------MERGE REFERALS

MERGE		Dim.Referrals AS TARGET
USING		(	
			 SELECT DISTINCT RefSourceID, Ref_company,
							 BINARY_CHECKSUM(Ref_company) Referral_CheckSum
			 FROM			 #FullDenormalizedTable 
			)	AS SOURCE
ON			TARGET.ReferralSourceID = SOURCE.RefSourceID

WHEN	MATCHED and  TARGET.Referral_CheckSum <> SOURCE.Referral_CheckSum
THEN		
			UPDATE
			SET			TARGET.Referral_Company = SOURCE.Ref_company

					
WHEN	NOT MATCHED
THEN		
			INSERT		(ReferralSourceID, Referral_Company, Referral_CheckSum)
			VALUES		(SOURCE.RefSourceID,SOURCE.Ref_company, BINARY_CHECKSUM(SOURCE.Ref_company));

/*
SELECT *
FROM Dim.Referrals
*/
--==================================================================--END OF DIM.REFERRAL

IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Dim.Status' and xtype='U') 

BEGIN

CREATE TABLE Dim.Status
						( Status_Key INT PRIMARY KEY  IDENTITY(1,1), StatusID INT,StatusDescription NVARCHAR(50),
						  Active BIT,Status_CheckSum INT)

END

-----------------------------------MERGE DIM.STATUS

MERGE  Dim.Status AS TARGET
USING			  (
				   SELECT DISTINCT 	StatusID ,StatusDesc,Active,
									BINARY_CHECKSUM(StatusDesc) Status_CheckSum	
				   FROM				#FullDenormalizedTable 
				  )	AS SOURCE
ON			TARGET.StatusID = SOURCE.StatusID

WHEN	MATCHED AND 	TARGET.Status_CheckSum <> SOURCE.Status_CheckSum
THEN		
		UPDATE
		SET					TARGET.StatusDescription  = SOURCE.StatusDesc 	
WHEN	NOT MATCHED
THEN 
				INSERT       (
							  StatusID,StatusDescription,Active,Status_CheckSum) 
				VALUES       (
							  SOURCE.StatusID,SOURCE.StatusDesc,SOURCE.Active,SOURCE.Status_CheckSum
							  ) ;

/*
SELECT *
FROM Dim.Status
*/
--================================================================--END OF DIM.Status

---------------------------------FACT.JobOrderCost


 IF NOT EXISTS (SELECT * FROM SYSOBJECTS where name='Fact.JobOrderCost' and xtype='U') 
	
BEGIN
	  
 CREATE TABLE Fact.JobOrderCost
	 (

	    JobOrderCost_Key INT PRIMARY KEY IDENTITY (1,1), 
		RepairOrder_Key INT NOT NULL FOREIGN KEY REFERENCES  Dim.RepairOrders(RepairOrder_Key),
		Referral_Key INT NOT NULL FOREIGN KEY REFERENCES  Dim.Referrals(Referral_Key),
		Shop_Key INT NOT NULL FOREIGN KEY REFERENCES Dim.Shop_Locations(Shop_Key),
		Category_Key INT NOT NULL FOREIGN KEY REFERENCES Dim.Category(Category_Key),
		Status_Key INT NOT NULL FOREIGN KEY REFERENCES Dim.Status(Status_Key),
		Order_Number INT,
		OrderCategoryType Varchar(100),
		OrderCategory Varchar(100),
		Cost Money,
		JobOrderCost_CheckSum INT
	 )    
	
END


---------------------------------------MERGE FACT.JobOrderCost

	
MERGE		Fact.JobOrderCost AS TARGET
USING		(	SELECT		RO.RepairOrder_Key,RF.Referral_Key,SL.Shop_Key,C.Category_Key,S.Status_Key,
							F.RO_NBR,F.CategoryType,F.Category, F.ChargeType,F.Cost,BINARY_CHECKSUM(RepairOrder_Key,
							Referral_Key,SL.Shop_Key,C.Category_Key, S.Status_Key,F.RO_NBR,CategoryType,
							F.Category,Cost) JobOrderCostCheckSum
							
				FROM		#FullDenormalizedTable AS F
				LEFT JOIN    Dim.RepairOrders AS RO
				ON			F.RO_NBR = RO.Ro_Nbr 
				LEFT JOIN	 Dim.Referrals AS RF
				ON			F.RefSourceID = RF.ReferralSourceID
				LEFT JOIN	 Dim.Shop_Locations AS SL
				ON			F.ShopID = SL.ShopID
				LEFT JOIN    Dim.Status AS S
				ON          F.StatusID = S.StatusID
				LEFT JOIN    Dim.Category AS C
				ON          F.CategoryKey = C.CategoryID
			) AS SOURCE
ON			TARGET.Order_Number = SOURCE.RO_NBR

WHEN		MATCHED and  TARGET.JobOrderCost_CheckSum <> SOURCE.JobOrderCostCheckSum
THEN		
			UPDATE
			SET		
					TARGET.RepairOrder_Key = SOURCE.RepairOrder_Key,
					TARGET.Referral_Key = SOURCE.Referral_Key,
					TARGET.Shop_Key = SOURCE.Shop_Key,
					TARGET.Category_Key = SOURCE.Category_Key,
					TARGET.Status_Key = SOURCE.Status_Key,
					TARGET.Order_Number = SOURCE.RO_NBR,
					TARGET.OrderCategoryType = SOURCE.CategoryType,
					TARGET.OrderCategory = SOURCE.Category,
					TARGET.Cost = SOURCE.Cost,
					TARGET.JobOrderCost_CheckSum = SOURCE.JobOrderCostCheckSum

WHEN		NOT MATCHED
THEN		
			INSERT		(
			             RepairOrder_Key,Referral_Key,Shop_Key,Category_Key,Status_Key,Order_Number,
						 OrderCategoryType,OrderCategory,Cost,JobOrderCost_CheckSum
						)
			
			VALUES		(
			             SOURCE.RepairOrder_Key,SOURCE.Referral_Key,
						 SOURCE.Shop_Key,SOURCE.Category_Key,SOURCE.Status_Key,SOURCE.RO_NBR,SOURCE.CategoryType,
						 SOURCE.Category,SOURCE.Cost,SOURCE.JobOrderCostCheckSum
						 );
END


--=================================================THE END ===============================================================

/*
SELECT *
FROM  Fact.JobOrderCost
*/

/*

sp_executesql Usp_LoadEstimateDataDW

*/


GO


