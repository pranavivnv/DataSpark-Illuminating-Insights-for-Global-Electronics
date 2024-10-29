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
SELECT Subcategory, COUNT(*) AS subcategory_count
FROM products
GROUP BY Subcategory;