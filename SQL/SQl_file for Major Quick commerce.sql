-- पुरानी टेबल हटा दें ताकि नई फ्रेश टेबल बने
DROP TABLE IF EXISTS Cleaned_quickcommerce_major_v2_nlp;

CREATE TABLE Cleaned_quickcommerce_major_v2_nlp AS
WITH Base_Standardization AS (
 SELECT 
        OrderID,
        COALESCE(Nullif(trim(CustomerID),''), 'UNKNOWN') AS CustomerID,
        
        -- Standardize Dates
          CASE
			WHEN OrderDate LIKE '%-%-%' 
				AND LENGTH(OrderDate) = 10
			THEN STR_TO_DATE(OrderDate, '%Y-%m-%d')

			WHEN OrderDate LIKE '%/%/%'
			THEN STR_TO_DATE(OrderDate, '%d/%m/%Y')

			WHEN OrderDate LIKE '%-%-%'
			THEN STR_TO_DATE(OrderDate, '%m-%d-%Y')

			WHEN OrderDate LIKE '%-%-%'
			THEN STR_TO_DATE(OrderDate, '%d-%b-%Y')

			ELSE NULL
		END AS OrderDate,
        
        -- Standardize Gurugram Area Names
           
        CASE 
            when Area like '%45%' then 'Sector 45'
			when Area like '%DLF%' then 'DLF Phase 3'
			when Area like '%s%a%R%' then 'Sohna Road'
			when Area like '%cyb%' then 'Cyber Hub'
			when Area like '%G%C%R%' then 'Golf Course Road'
            ELSE TRIM(Area)
        END AS Area_Name,

        -- Clean ActualTime
        
		case
			when ActualTime like '%Delay%' OR ActualTime is Null OR ActualTime = '' 
            then (Prep_Time + Transit_Time + 15) 
			when ActualTime like '%min%' 
            then cast(replace(ActualTime,'mins','') as unsigned)
			else cast(ActualTime as unsigned)
		end as Actual_Time_Mins,
       
               
		cast(sentiment_Score as decimal(10,2)) as Sentiment_score,
        Review,
        Sentiment,
        -- STEP A: Convert blanks to NULLs so they can be imputed
        NULLIF(TRIM(Total_Amount), '') AS Raw_Total_Amount,
        
        -- Standardize Case for Status
        CONCAT(UPPER(LEFT(Delivery_Status, 1)), LOWER(SUBSTRING(Delivery_Status, 2))) AS Delivery_Status,
        cast(Prep_Time AS unsigned) as Base_Prep_Time,
        cast(Transit_Time AS unsigned) as Base_Transit_Time
    FROM quickcommerce_major_v2_nlp
    WHERE OrderID NOT IN (
        SELECT OrderID FROM (SELECT OrderID FROM quickcommerce_major_v2_nlp GROUP BY OrderID HAVING COUNT(*) > 1) d
    )
),
Variance_Injection AS (
    SELECT *,
        -- Adding Artificial Variance (Problem Areas)
        CASE 
			WHEN Area_Name = 'Sector 45' THEN Base_Prep_Time + 7 -- Kitchen Issue (Delayed)
			WHEN Area_Name IN ('Golf Course Road', 'DLF Phase 3') THEN LEAST(Base_Prep_Time, 4) -- Very Efficient (On-Time)
			ELSE LEAST(Base_Prep_Time, 5) -- Normal Areas (Mostly On-Time or Minor Delay)
		END AS Prep_Time,

		CASE 
			WHEN Area_Name = 'Cyber Hub' THEN Base_Transit_Time + 8 -- Traffic Issue (Delayed)
			WHEN Area_Name IN ('Golf Course Road', 'DLF Phase 3') THEN LEAST(Base_Transit_Time, 4) -- Very Efficient (On-Time)
			ELSE LEAST(Base_Transit_Time, 5) -- Normal Areas (Mostly On-Time or Minor Delay)
		END AS Transit_Time,
        
        AVG(CAST(Raw_Total_Amount AS DECIMAL(10,2))) OVER(PARTITION BY Area_Name) AS Area_Avg_Amount
    FROM Base_Standardization
)
SELECT 
    OrderID,
    CustomerID,
    OrderDate,
    Area_Name,
    Actual_Time_Mins,
    Sentiment_Score,
    Sentiment,
    Review,
    ROUND(COALESCE(CAST(Raw_Total_Amount AS DECIMAL(10,2)), Area_Avg_Amount), 2) AS Total_Amount,
    Delivery_Status,
    Prep_Time,
    Transit_Time,
    -- Final Calculations based on Modified Data
    (Prep_Time + Transit_Time) as Actual_Time,
	((Prep_Time + Transit_Time) - 10 ) AS Delivery_Lag -- Using 10 mins as Promise Time
FROM Variance_Injection;










