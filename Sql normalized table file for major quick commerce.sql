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
    c.Actual_Time,
    c.sentiment,
    c.Sentiment_Score,
    c.Total_Amount,
    c.Prep_Time,
    c.Transit_Time,
    c.Delivery_Lag,
    c.Review
FROM cleaned_quickcommerce_major_v2_nlp c
JOIN Dim_Areas a ON c.Area_Name = a.Area_Name
JOIN Dim_Status s ON c.Delivery_Status = s.Delivery_Status;
