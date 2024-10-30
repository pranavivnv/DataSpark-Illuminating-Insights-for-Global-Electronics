use DataSpark_db
-- Select all columns from each table
SELECT * FROM customers;
SELECT * FROM exchange;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM stores;

-- Describe tables
-- No change needed for describing tables

-- Check and convert data types to date (if needed)
-- customer table
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'customers';

-- You might need to convert Birthday to a date format depending on your data
-- Example using STR_TO_DATE if Birthday is stored as a string
UPDATE customers SET Birthday = STR_TO_DATE(Birthday, '%Y-%m-%d');
ALTER TABLE customers MODIFY Birthday DATE;  -- Modify column type to date

-- sales table
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'sales';

-- You might need to convert Order_Date to a date format depending on your data
UPDATE sales SET Order_Date = STR_TO_DATE(Order_Date, '%Y-%m-%d');
ALTER TABLE sales MODIFY Order_Date DATE;  -- Modify column type to date

-- stores table
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'stores';

-- You might need to convert Open_Date to a date format depending on your data
UPDATE stores SET Open_Date = STR_TO_DATE(Open_Date, '%Y-%m-%d');
ALTER TABLE stores MODIFY Open_Date DATE;  -- Modify column type to date

-- exchange rate table
UPDATE exchange SET Date = STR_TO_DATE(Date, '%Y-%m-%d');
ALTER TABLE exchange MODIFY Date DATE;  -- Modify column type to date

-- Queries to get insights from 5 tables

-- 1. Overall female count
SELECT COUNT(*) AS Female_count
FROM customers
WHERE Gender = 'Female';

-- 2. Overall male count
SELECT COUNT(*) AS Male_count
FROM customers
WHERE Gender = 'Male';

-- 3. Count of customers in country-wise
SELECT sd.Country, COUNT(DISTINCT c.CustomerKey) AS customer_count
FROM sales c
JOIN stores sd ON c.StoreKey = sd.StoreKey
GROUP BY sd.Country
ORDER BY customer_count DESC;

-- 4. Overall count of customers
SELECT COUNT(DISTINCT s.CustomerKey) AS customer_count
FROM sales s;

-- 5. Count of stores in country-wise
SELECT Country, COUNT(*) AS store_count
FROM stores
GROUP BY Country
ORDER BY store_count DESC;

-- 6. Store-wise sales
SELECT s.StoreKey, sd.Country, SUM(Unit_Price_USD * s.Quantity) AS total_sales_amount
FROM products pd
JOIN sales s ON pd.ProductKey = s.ProductKey
JOIN stores sd ON s.StoreKey = sd.StoreKey
GROUP BY s.StoreKey, sd.Country;

-- 7. Overall selling amount
SELECT SUM(Unit_Price_USD * sd.Quantity) AS total_sales_amount
FROM products pd
JOIN sales sd ON pd.ProductKey = sd.ProductKey;

-- 8. CP and SP difference and profit
SELECT
  Product_name,
  Unit_price_USD,
  Unit_Cost_USD,
  ROUND(Unit_price_USD - Unit_Cost_USD, 2) AS diff,
  ROUND((Unit_price_USD - Unit_Cost_USD) / Unit_Cost_USD * 100, 2) AS profit
FROM
  products;

-- 9. Brand-wise selling amount
SELECT
  Brand,
  ROUND(SUM(Unit_price_USD * sd.Quantity), 2) AS sales_amount
FROM
  products pd
JOIN
  sales sd ON pd.ProductKey = sd.ProductKey
GROUP BY
  Brand;

-- 10. Subcategory-wise selling amount
SELECT
    Subcategory,
    COUNT(Subcategory) AS subcategory_count
FROM
    product_details
GROUP BY
    Subcategory;

SELECT
    Subcategory,
    ROUND(SUM(Unit_price_USD * sd.Quantity), 2) AS TOTAL_SALES_AMOUNT
FROM
    product_details pd
JOIN
    sales_details sd ON pd.ProductKey = sd.ProductKey
GROUP BY
    Subcategory
ORDER BY
    TOTAL_SALES_AMOUNT DESC;
        -- 11. Country-wise overall sales
SELECT s.Country, SUM(pd.Unit_price_USD * sd.Quantity) AS total_sales
FROM products pd
JOIN sales sd ON pd.ProductKey = sd.ProductKey
JOIN stores s ON sd.StoreKey = s.StoreKey
GROUP BY s.Country;

SELECT s.Country, COUNT(DISTINCT s.StoreKey) AS num_stores, SUM(pd.Unit_price_USD * sd.Quantity) AS total_sales
FROM products pd
JOIN sales sd ON pd.ProductKey = sd.ProductKey
JOIN stores s ON sd.StoreKey = s.StoreKey
GROUP BY s.Country;
-- 12. Year-wise brand sales
SELECT
    YEAR(Order_Date) AS order_year,
    pd.Brand,
    ROUND(SUM(Unit_price_USD * sd.Quantity), 2) AS year_sales
FROM
    sales sd
JOIN
    products pd ON sd.ProductKey = pd.ProductKey
GROUP BY
    YEAR(Order_Date),
    pd.Brand;
    -- 13. Overall sales with quantity
    SELECT
    Brand,
    SUM(Unit_Price_USD * sd.Quantity) AS sp,
    SUM(Unit_Cost_USD * sd.Quantity) AS cp,
    (SUM(Unit_Price_USD * sd.Quantity) - SUM(Unit_Cost_USD * sd.Quantity)) / SUM(Unit_Cost_USD * sd.Quantity) * 100 AS profit
FROM
    products pd
JOIN
    sales sd ON sd.ProductKey = pd.ProductKey
GROUP BY
    Brand;
    -- 14. Month-wise sales with quantity
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m-01') AS month,
    SUM(Unit_Price_USD * sd.Quantity) AS sp_month
FROM
    sales sd
JOIN
    products pd ON sd.ProductKey = pd.ProductKey
GROUP BY
    DATE_FORMAT(Order_Date, '%Y-%m-01');
    -- 15. Month and year-wise sales with quantity
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m-01') AS month,
    YEAR(Order_Date) AS year,
    pd.Brand,
    SUM(Unit_Price_USD * sd.Quantity) AS sp_month
FROM
    sales sd
JOIN
    products pd ON sd.ProductKey = pd.ProductKey
GROUP BY
    DATE_FORMAT(Order_Date, '%Y-%m-01'),
    YEAR(Order_Date),
    pd.Brand;
    -- 16. Year-wise sales
SELECT
    YEAR(Order_Date) AS year,
    SUM(Unit_Price_USD * sd.Quantity) AS sp_year
FROM
    sales sd
JOIN
    products pd ON sd.ProductKey = pd.ProductKey
GROUP BY
    YEAR(Order_Date);
    -- 17. Comparing current month and previous month
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m-01') AS month,
        SUM(Unit_Price_USD * sd.Quantity) AS sales
    FROM
        sales sd
    JOIN
        products pd ON sd.ProductKey = pd.ProductKey
    GROUP BY
        DATE_FORMAT(Order_Date, '%Y-%m-01')
)
SELECT
    month,
    sales,
    LAG(sales) OVER (ORDER BY month) AS Previous_Month_Sales
FROM
    monthly_sales;
    -- 18. Comparing current year and previous year sales
WITH yearly_sales AS (
    SELECT
        YEAR(Order_Date) AS year,
        SUM(Unit_Price_USD * sd.Quantity) AS sales
    FROM
        sales sd
    JOIN
        products pd ON sd.ProductKey = pd.ProductKey
    GROUP BY
        YEAR(Order_Date)
)
SELECT
    year,
    sales,
    LAG(sales) OVER (ORDER BY year) AS Previous_Year_Sales
FROM
    yearly_sales;
    -- 19. Month-wise profit
WITH monthly_profit AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m-01') AS month,
        SUM(Unit_Price_USD * sd.Quantity) - SUM(Unit_Cost_USD * sd.Quantity) AS profit
    FROM
        sales sd
    JOIN
        products pd ON sd.ProductKey = pd.ProductKey
    GROUP BY
        DATE_FORMAT(Order_Date, '%Y-%m-01')
)
SELECT
    month,
    profit,
    LAG(profit) OVER (ORDER BY month) AS Previous_Month_Profit,
    ROUND((profit - LAG(profit) OVER (ORDER BY month)) / LAG(profit) OVER (ORDER BY month) * 100, 2) AS profit_percent
FROM
    monthly_profit;
    -- 20. Year-wise profit
WITH yearly_profit AS (
    SELECT
        YEAR(Order_Date) AS year,
        SUM(Unit_Price_USD * sd.Quantity) - SUM(Unit_Cost_USD * sd.Quantity) AS profit
    FROM
        sales sd
    JOIN
        products pd ON sd.ProductKey = pd.ProductKey
    GROUP BY
        YEAR(Order_Date)
)
SELECT
    year,
    profit,
    LAG(profit) OVER (ORDER BY year) AS Previous_Year_Profit,
    ROUND((profit - LAG(profit) OVER (ORDER BY year)) / LAG(profit) OVER (ORDER BY year) * 100, 2) AS profit_percent
FROM
    yearly_profit;