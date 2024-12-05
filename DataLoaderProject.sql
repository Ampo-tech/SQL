USE ImportExportTransactions
GO

/*
  Loading Products dimension data ...
*/
GO

INSERT INTO dim.Products (Product_id, Products_Sold)
SELECT id_category,
       Products_Sold
FROM Amazon.dbo.dim_category
;
GO

/*
  Loading Shipping_Method dimension data ...
*/
GO

INSERT INTO dim.Shipping_Method (Shipping_id, Shipping_Method)
SELECT id_shipping_method,
       Shipping_Method
FROM Amazon.dbo.dim_shipping_method
;
GO

/*
  Loading Transaction_Type dimension data ...
*/

INSERT INTO dim.Transaction_Type (Transaction_id, Transaction_Type)
SELECT id_import_export,
       Transaction_Type
FROM Amazon.dbo.dim_import_export


/*********************************************************/
/***********  Loading Import_Export fact data  ***********/
/*********************************************************/



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
	

/*
  Load the calendar dimension data ...
*/

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


