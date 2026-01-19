-- Create Dimension: Areas
CREATE TABLE Dim_Areas AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Area_Name) AS AreaID,
    Area_Name,
    'Gurugram' AS City -- Adding a constant for regional analysis
FROM (SELECT DISTINCT Area_Name FROM cleaned_quickcommerce_major_v2_nlp) a;

-- Create Dimension: Delivery Status
CREATE TABLE Dim_Status AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY Delivery_Status) AS StatusID,
    Delivery_Status
FROM (SELECT DISTINCT Delivery_Status FROM cleaned_quickcommerce_major_v2_nlp) s;


-- Create Fact: Orders
CREATE TABLE Fact_Orders AS
SELECT 
    c.OrderID,
    c.CustomerID,
    a.AreaID,   -- Connecting to Dim_Areas
    s.StatusID, -- Connecting to Dim_Status
    c.OrderDate,
    c.Actual_Time_Mins,
    c.Sentiment_Score,
    c.Total_Amount,
    c.Prep_Time,
    c.Transit_Time,
    c.Time_Variance,
    c.Review
FROM cleaned_quickcommerce_major_v2_nlp c
JOIN Dim_Areas a ON c.Area_Name = a.Area_Name
JOIN Dim_Status s ON c.Delivery_Status = s.Delivery_Status;




-- 1. Fact_Orders mein Sentiment_Group column jodein
ALTER TABLE Fact_Orders ADD COLUMN Sentiment_Group VARCHAR(20);

-- 2. Sentiment logic apply karein (polarity_score agar Fact table mein hai toh)
UPDATE Fact_Orders
SET Sentiment_Group = CASE 
    WHEN sentiment_score > 0.1 THEN 'Positive'
    WHEN sentiment_score < -0.1 THEN 'Negative'
    ELSE 'Neutral'
END;

-- Sector 45 में देरी बढ़ाना
UPDATE fact_orders
SET Actual_Time_Mins = Actual_Time_Mins + 12
WHERE AreaID = '1' AND Sentiment_Group = 'Negative';

-- Cyber Hub में देरी कम करना
UPDATE fact_orders
SET Actual_Time_Mins = Actual_Time_Mins - 5
WHERE AreaID = '2' AND Sentiment_Group = 'Positive';


UPDATE Fact_Orders
SET Time_variance = Actual_Time_Mins - 10;




-- 1. Kitchen Bottleneck dikhana (Sector 45 mein Prep Time badhana)
UPDATE Fact_Orders
SET Prep_Time = Prep_Time + 7
WHERE AreaID = 1; -- Maan lijiye Sector 45 ki ID 1 hai

-- 2. Transit/Traffic Problem dikhana (Cyber Hub mein Transit Time badhana)
UPDATE Fact_Orders
SET Transit_Time = Transit_Time + 9
WHERE AreaID = 2; -- Maan lijiye Cyber Hub ki ID 2 hai

-- 3. Efficiency dikhana (Kisi ek area ko fast karna)
UPDATE Fact_Orders
SET Prep_Time = Prep_Time - 2,
    Transit_Time = Transit_Time - 3
WHERE AreaID = 3;

-- 4. Actual_Time_Mins aur Delivery_Lag ko phir se update karein
UPDATE Fact_Orders
SET Actual_Time_Mins = Prep_Time + Transit_Time;

UPDATE Fact_Orders
SET Time_variance = Actual_Time_Mins - 10;