USE ImportExportTransactions
GO

/*********************************************************/
/******************    Schema DDL       ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA dim AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA stg AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'fact' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA f AUTHORIZATION dbo;'
END
;

/*********************************************************/
/******************  Products DIM DDL   ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Products')
BEGIN
	CREATE TABLE dim.Products(
	Product_id BIGINT NOT NULL,
	Products_Sold nvarchar(100) NULL
)
;

ALTER TABLE dim.Products
ADD CONSTRAINT PK_Products_LUP PRIMARY KEY(Product_id);

END

GO

INSERT INTO dim.Products (Product_id, Products_Sold)
SELECT id_category,
       Products_Sold
FROM Amazon.dbo.dim_category



/*********************************************************/
/****************** Calendar DIM Script ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Calendar')
BEGIN
-- Create the Calendar table
CREATE TABLE dim.Calendar
(
    pkCalendar INT NULL,
    DateValue DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
	Qtr VARCHAR(3) NOT NULL,
    Month INT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
	MonthShort VARCHAR(3) NOT NULL,
    Week INT NOT NULL,
    Day INT NOT NULL,
	DayName VARCHAR(10) NOT NULL,
	DayShort VARCHAR(3) NOT NULL,
    IsWeekday BIT NOT NULL,
	Weekday VARCHAR(3) NOT NULL
)
;

	ALTER TABLE dim.Calendar
	ADD CONSTRAINT PK_Calendar_Julian PRIMARY KEY(pkCalendar);

	ALTER TABLE dim.Calendar
    ADD CONSTRAINT UC_Calendar UNIQUE (DateValue);
END
GO


/*********************************************************/
/***************  Shipping_Method DIM DDL  ***************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Shipping_Method')
BEGIN
CREATE TABLE dim.Shipping_Method (
	Shipping_id BIGINT NOT NULL,
	Shipping_Method nvarchar(MAX) NULL
)


	ALTER TABLE dim.Shipping_Method
	ADD CONSTRAINT PK_Shipping_Method PRIMARY KEY(Shipping_id);


END

GO

INSERT INTO dim.Shipping_Method (Shipping_id, Shipping_Method)
SELECT id_shipping_method,
       Shipping_Method
FROM Amazon.dbo.dim_shipping_method


/*********************************************************/
/***************  Transaction_Type DIM DDL  **************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Transaction_Type')
BEGIN
CREATE TABLE dim.Transaction_Type (
	Transaction_id BIGINT NOT NULL,
	Transaction_Type nvarchar(MAX) NULL
)


ALTER TABLE dim.Transaction_Type
ADD CONSTRAINT PK_Transaction_Type PRIMARY KEY(Transaction_id)

INSERT INTO dim.Transaction_Type (Transaction_id, Transaction_Type)
SELECT id_import_export,
       Transaction_Type
FROM Amazon.dbo.dim_import_export


/*********************************************************/
/***************  f.Import_Export   **************/
/*********************************************************/

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'f' AND TABLE_NAME = 'Import_Export')
BEGIN 
	DROP TABLE f.Import_Export;
END

CREATE TABLE f.Import_Export(
    pkCalendar INT NULL,
	Transaction_id BIGINT NOT NULL,
	Product_id BIGINT NOT NULL,
	Shipping_id BIGINT NOT NULL,
	Country nvarchar(max) NULL,
	Product nvarchar(max) NULL,
	Quantity bigint NULL,
	Value float NULL,
	Date datetime2(0) NULL,
	Port nvarchar(max) NULL,
	Customs_Code bigint NULL,
	Weight float NULL,
	Supplier nvarchar(max) NULL,
	Customer nvarchar(max) NULL,
	Invoice_Number bigint NULL,
	Payment_Terms nvarchar(max) NULL,
	Total_Transaction_Count nvarchar(max) NULL,
	Year bigint NULL
)
;




ALTER TABLE f.Import_Export
ADD CONSTRAINT FK_Import_Export_Calendar FOREIGN KEY (pkCalendar)
	REFERENCES dim.Calendar(pkCalendar)

--ALTER TABLE f.Transaction_fact CHECK CONSTRAINT FK_f.Transaction_fact_Calendar
GO

ALTER TABLE f.Import_Export
ADD  CONSTRAINT FK_Import_Export_Products FOREIGN KEY(Product_id)
REFERENCES dim.Products(Product_id)
GO

ALTER TABLE f.Transaction_fact CHECK CONSTRAINT FK_f.Transaction_fact_locations
GO

ALTER TABLE f.Import_Export
ADD  CONSTRAINT FK_Import_Export_Shipping_Method FOREIGN KEY(Shipping_id)
REFERENCES dim.Shipping_Method(Shipping_id)
GO

ALTER TABLE f.Transaction_fact CHECK CONSTRAINT FK_Transaction_fact_products
GO

ALTER TABLE f.Import_Export
ADD  CONSTRAINT FK_Import_Export_Transaction_Type FOREIGN KEY(Transaction_id)
REFERENCES dim.Transaction_Type(Transaction_id)




INSERT INTO f.Import_Export(Transaction_id, Product_id, Shipping_id, Country, [Product], Quantity, [Value],  [Date],
             [Port], [Weight], Supplier,Customer, Invoice_Number, Payment_Terms, Total_Transaction_Count, [Year])
SELECT 
	id_import_export,
	id_category,
	id_shipping_method,
	Country,
	[Product], 
	Quantity, 
	[Value],
	[Date],
	[Port],
	Customs_Code, 
	[Weight],
	Supplier,
	Customer,
	Invoice_Number,
	Payment_Terms,
	Total_Transaction_Count,
	[Year]
FROM Amazon.dbo.fact_import_export 
	
	
	 
	
	
	
	
	
	
	
	
	
	
	
	
	
	




/*********************************************************/
/***************  Imports_Export STG DDL  ****************/
/*********************************************************/

CREATE TABLE Stg.Imports_Exports (
	Transaction_ID nvarchar(max) NULL,
	Country nvarchar(max) NULL,
	Product nvarchar(max) NULL,
	Import_Export nvarchar(max) NULL,
	Quantity bigint NULL,
	Value float NULL,
	Date nvarchar(max) NULL,
	Category nvarchar(max) NULL,
	Port nvarchar(max) NULL,
	Customs_Code bigint NULL,
	Weight float NULL,
	Shipping_Method nvarchar(max) NULL,
	Supplier nvarchar(max) NULL,
	Customer nvarchar(max) NULL,
	Invoice_Number bigint NULL,
	Payment_Terms nvarchar(max) NULL
 )
GO

WITH RECURSIVE CalendarDates AS (
    -- Starting point: January 1, 2019
    SELECT '2019-01-01' AS DateValue
    UNION ALL
    -- Recursive part: Add one day at a time
    SELECT DATE_ADD(DateValue, INTERVAL 1 DAY)
    FROM CalendarDates
    WHERE DateValue < '2024-12-31'
)
-- Insert the data into the dim.Calendar table
INSERT INTO dim.Calendar 
(
    pkCalendar, 
    DateValue, 
    Year, 
    Quarter, 
    Qtr, 
    Month, 
    MonthName, 
    MonthShort, 
    Week, 
    Day, 
    DayName, 
    DayShort, 
    IsWeekday, 
    Weekday
)
SELECT 
    NULL, -- pkCalendar (auto-incremented if applicable)
    DateValue, -- DateValue
    YEAR(DateValue), -- Year
    CASE 
        WHEN MONTH(DateValue) IN (1, 2, 3) THEN 1
        WHEN MONTH(DateValue) IN (4, 5, 6) THEN 2
        WHEN MONTH(DateValue) IN (7, 8, 9) THEN 3
        ELSE 4 
    END, -- Quarter
    CASE 
        WHEN MONTH(DateValue) IN (1, 2, 3) THEN 'Q1'
        WHEN MONTH(DateValue) IN (4, 5, 6) THEN 'Q2'
        WHEN MONTH(DateValue) IN (7, 8, 9) THEN 'Q3'
        ELSE 'Q4'
    END, -- Qtr
    MONTH(DateValue), -- Month
    DATENAME(MONTH, DateValue), -- MonthName
    LEFT(DATENAME(MONTH, DateValue), 3), -- MonthShort
    DATEPART(WEEK, DateValue), -- Week
    DAY(DateValue), -- Day
    DATENAME(WEEKDAY, DateValue), -- DayName
    LEFT(DATENAME(WEEKDAY, DateValue), 3), -- DayShort
    CASE 
        WHEN DATENAME(WEEKDAY, DateValue) IN ('Saturday', 'Sunday') THEN 0
        ELSE 1
    END, -- IsWeekday (0 = Weekend, 1 = Weekday)
    LEFT(DATENAME(WEEKDAY, DateValue), 3) -- Weekday (first three letters of the weekday name)
FROM CalendarDates;

-- Optionally, you can stop the recursion if your database requires it
-- (depends on the DBMS; in some cases, a LIMIT is needed to avoid exceeding recursion depth).



INSERT INTO dim.Calendar
(
    pkCalendar, 
    DateValue, 
    Year, 
    Quarter, 
    Qtr, 
    Month, 
    MonthName, 
    MonthShort, 
    Week, 
    Day, 
    DayName, 
    DayShort, 
    IsWeekday, 
    Weekday
)
VALUES
(
    NULL, -- pkCalendar can be NULL if it's auto-incremented
    '2024-12-04', -- DateValue
    YEAR('2024-12-04'), -- Year
    CASE 
        WHEN MONTH('2024-12-04') IN (1, 2, 3) THEN 1
        WHEN MONTH('2024-12-04') IN (4, 5, 6) THEN 2
        WHEN MONTH('2024-12-04') IN (7, 8, 9) THEN 3
        ELSE 4 
    END, -- Quarter
    CASE 
        WHEN MONTH('2024-12-04') IN (1, 2, 3) THEN 'Q1'
        WHEN MONTH('2024-12-04') IN (4, 5, 6) THEN 'Q2'
        WHEN MONTH('2024-12-04') IN (7, 8, 9) THEN 'Q3'
        ELSE 'Q4'
    END, -- Qtr
    MONTH('2024-12-04'), -- Month
    DATENAME(MONTH, '2024-12-04'), -- MonthName
    LEFT(DATENAME(MONTH, '2024-12-04'), 3), -- MonthShort
    DATEPART(WEEK, '2024-12-04'), -- Week
    DAY('2024-12-04'), -- Day
    DATENAME(WEEKDAY, '2024-12-04'), -- DayName
    LEFT(DATENAME(WEEKDAY, '2024-12-04'), 3), -- DayShort
    CASE 
        WHEN DATENAME(WEEKDAY, '2024-12-04') IN ('Saturday', 'Sunday') THEN 0
        ELSE 1
    END, -- IsWeekday
    LEFT(DATENAME(WEEKDAY, '2024-12-04'), 3) -- Weekday
);
