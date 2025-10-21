-- Creation of the table Orders 
drop table if exists orders;
create table orders(
orderId varchar,
OrderDate date,
Yea Int,
ShipMode Varchar(30),
CustomerID varchar(30),
Segment Varchar(30),
Country Varchar(30),
City Varchar(30),
Stat Varchar(30),
PostalCode int,
Region Varchar(30),
Product_ID Varchar(30),
Sales_Amount numeric(10,2),
Quantity int,
Discount numeric(4,2),
Profit Numeric(10,2),
Sales_person varchar(30)
);
select * from Orders;

--Creation of the table Product----
DROP TABLE IF EXISTS Product;
CREATE TABLE Product (
    Category VARCHAR(20),
    SubCategory VARCHAR(20),
    ProductName VARCHAR(150),
    ProductID VARCHAR(20)
);
select * from Product;

-- Creation of the table Customer-----
DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer(
CustomerID varchar(10),
CustomerName Varchar(30)
);
select * from Customer;

-- Creation of the table RegioHead------
DROP TABLE IF EXISTS RegionHead;
CREATE TABLE RegionHead(
Person varchar(20),
Region Varchar(10)
);
select * from RegionHead;

-- Creation of the table Returned---------
DROP TABLE IF EXISTS Returned;
CREATE TABLE Returned(
Returned varchar(5),
OrderId Varchar(20)
);
select * from Returned;

-- Creation of the table SalesPerson --------
DROP TABLE IF EXISTS SalesPerson;
CREATE TABLE SalesPerson(
ID  varchar(10),
name Varchar(30)
);
select * from SalesPerson;

-- Creation of the table SalesTarget --------
DROP TABLE IF EXISTS SalesTarget;
CREATE TABLE SalesTarget(
State varchar(20),
Year int,
Month int,
Target int
);
select * from Salestarget;





-- Now Lets start finding the and comparing the Metrices related to the sales
-- Finding the total revenue of the company.
select sum(sales_amount*quantity) as "Total revenue",
		count(distinct orderid) as "Total Orders",
		round(sum(sales_amount*quantity)/count(distinct orderid),2) as "Average Order Value",
		round(sum(quantity)/count(distinct orderid),1) as "Average Order Quantity",
		round(sum(quantity*profit),2) as "Total Profit",
		round(sum(quantity*profit)*100/sum(sales_amount*quantity),2) as Margin
from Orders;
-- TOTAL REVENUE= 11488064.20
-- Total Number of orders=5009
-- Average Order Value=2293.48
-- Average Order Quantity=7.0
-- Total Profit= 1430431.86
-- Margin = 12.45%

-- Find the trend of the revenue with the year
select  yea, 
		sum(case when region='Central' then Sales_amount*quantity else 0 end) as Central,
		sum(case when region='East' then Sales_amount*quantity else 0 end) as East,
		sum(case when region='South' then Sales_amount*quantity else 0 end) as South ,
		sum(case when region='West' then Sales_amount*quantity else 0 end) as West,
		sum(Sales_amount*quantity) as "Total Revenue"
from Orders
group by yea
order by yea;
-- yea	Central		East		South		West	
-- 2018	103838.16	128680.45	103845.88	147883.07
-- 2019	102874.24	156332.01	71359.97	139966.24
-- 2020	147429.42	180685.95	93610.23	187480.26
-- 2021	147098.06	213082.95	122905.82	250128.36



-- Revenue trand with respect to the segment and categories.
select yea, sum(case when segment='Consumer' then sales_amount*quantity else 0 end) as Consumer,
		sum(case when segment='Corporate' then sales_amount*quantity else 0 end) as Corporate,
		sum(case when segment='Home Office' then sales_amount*quantity else 0 end ) as "Home Office"
from Orders
group by yea
order by  yea;
-- yea	consumer	corporate	home Office
2018	266096.88	128434.89	89715.79
2019	266535.89	128757.30	75239.27
2020	296863.97	207106.41	105235.48
2021	331904.60	241847.84	159462.75



-- Category wise  yealy revenue trend  
select o.yea, sum(case when category='Furniture' then sales_amount*quantity else 0 end) as Furniture,
			sum( case when category='Technology' then sales_amount*quantity else 0 end) as Technology,
			sum( case when category='Office Supplies' then sales_amount*quantity else 0 end) as "Office Supplies"
from Orders o left join product p
on o.product_id=p.productid
group by o.yea;
-- yea	Furniture	Technology	Office Supplies
2018	157192.89	175278.26	151776.41
2019	170518.26	162780.78	137233.42
2021	215387.28	271730.82	246097.09
2020	198901.55	226364.24	183940.07



-- which products were returned the most
with r_p as(
select o.orderid, o.product_id, o.region, o.quantity
from Orders o inner join returned r
on o.orderid= r.orderid and r.returned= 'Yes'
order by o.orderid)
, pdct as(
select product_id, sum(quantity) as quantity
from r_p
group by product_id
order by sum(quantity) desc)

select p.productname, quantity
from pdct inner join product p
on pdct.product_id=p.productid
order by quantity desc
;




--  find the category wise returned most by quantity and revenue both
with r_p as(
select o.orderid, o.product_id, o.region, o.quantity*o.sales_amount as reve
from Orders o inner join returned r
on o.orderid= r.orderid and r.returned= 'Yes'
order by o.orderid)

select p.category, sum(reve) as "Quantity returned"
from r_p left join product p
on r_p.product_id = p.productid
group by category
order by sum(reve) desc;
-- Category 	Quantity
-- Office Supplies	1835
-- Furniture"	654
-- Technology"	564



-- yealy returned quantity with respect to the category
with r_p as(
select o.orderid, o.product_id, o.region,o.yea, o.quantity
from Orders o inner join returned r
on o.orderid= r.orderid and r.returned= 'Yes'
order by o.orderid)

select r_p.yea, 
	sum( case when p.category='Office Supplies' then quantity else 0 end) as "Office Supplies",
	sum( case when p.category='Furniture' then quantity else 0 end) as "Furniture",
	sum( case when p.category='Technology' then quantity else 0 end) as "Technology"
from r_p left join product p
on r_p.product_id = p.productid
group by yea
order by yea;
-- yea	Office Supplies	Furniture	Technology
2018	308				117			100
2019	336				134			128
2020	509				162			119
2021	682				241			217



-- returned order with respect to the regions they belong to
-- yealy returned quantity with respect to the category
with r_p as(
select o.orderid, o.product_id, o.region,o.yea, o.quantity
from Orders o inner join returned r
on o.orderid= r.orderid and r.returned= 'Yes'
order by o.orderid)

select yea as year, 
	sum( case when region='Central' then quantity else 0 end) as "Central",
	sum( case when region='East' then quantity else 0 end) as "East",
	sum( case when region='West' then quantity else 0 end) as "West",
	sum( case when region='South' then quantity else 0 end) as "South"
from r_p 
group by yea
order by yea;
-- year Centra	East	West	South
-- 2018	93		102		286		44
-- 2019	67		142		327		62
-- 2020	69		131		514		76
-- 2021	121		168		771		80
--  Here we got to know that the West has the most returned quantity. We will have to focus on the delivery services there and look into it seriously.



-- Now lets check that if the order is returned what type of shipment mode they used and cheking the % for it.
select shipmode,count(distinct o.orderid) as "No of orders returned"
from orders o inner join returned r
on o.orderid = r.orderid
group by shipmode
-- Shipmode 		NO of orders
-- "Standard Class"	450
-- "Second Class"	134
-- "Same Day"		64
-- "First Class"	152



-- Predict profit taking discount as an input from user
select round(sum((sales_amount/(1- discount))*quantity),2) as "Non discounted Revenue", 
	sum((sales_amount- profit)*quantity) as "Cost",
	round(sum(((sales_amount/(1- discount))-(sales_amount- profit))*quantity),2) as "Profit if non Discounted"
from orders;
-- Non Discounted Revenue=14311864.35
-- Profit if sold on Non-Discounted price= 14311864.35



-- Doing the pereto analysis of the customer as well products who drive the revenues. or have bought at least ones or product that has been bought at least once
WITH customer_total_sale AS (
  SELECT 
    customerid, 
    SUM(sales_amount * quantity) AS total_sale
  FROM orders
  GROUP BY customerid
),
ranked AS (
  SELECT
    customerid,
    total_sale,
    ROW_NUMBER() OVER (ORDER BY total_sale DESC) AS rn,
    COUNT(*) OVER () AS total_customers,
    SUM(total_sale) OVER () AS grand_total,
    SUM(total_sale) OVER (ORDER BY total_sale DESC) AS running_total
  FROM customer_total_sale
)
SELECT
  customerid,
  total_sale,
  running_total,
  ROUND((running_total::numeric / grand_total) * 100, 2) AS cumulative_sales_pct,
  ROUND((rn::numeric / total_customers) * 100, 2) AS cumulative_customer_pct
FROM ranked
ORDER BY total_sale DESC;
-- Top 5% customers make the revenue of almost 22%
-- Top 10% make the revenue of ~34.5%
-- 20% Makes 50% of the revenue
-- 25% of customer makes 60% of the revenue



-- NOW LET's START WORKING ON THE CUSTOMER ANALYSIS 
-- let's see how many customers are getting added each month.
WITH first_order AS (
  SELECT customerid, MIN(orderdate) AS first_purchase_date
  FROM orders
  GROUP BY customerid
) 
SELECT
  TO_CHAR(first_purchase_date, 'YYYY-MM') AS cohort_month,
  COUNT(customerid) AS new_customers
FROM first_order
GROUP BY cohort_month
ORDER BY cohort_month;
-- Number of new customer has been drastically decreased after 2018.
-- I think company should focus on agetting inroduced to the new customers as well they should spend a bit on the maketing


-- DOING THE RFM ANALYSIS OF THE CUSTOMERS
-- RFM into 3 segments (High / Medium / Low) — analysis_date = 2021-11-01
WITH params AS (
  SELECT '2022-01-01'::date AS analysis_date
),

-- 1) RFM base
customer_rfm AS (
  SELECT
    customerid,
    MIN(orderdate)                  AS first_purchase_date,
    MAX(orderdate)                  AS last_purchase_date,
    ((SELECT analysis_date FROM params) - MAX(orderdate))::INT AS recency_days,
    COUNT(DISTINCT orderid)         AS frequency,
    SUM(sales_amount * COALESCE(quantity,1)) AS monetary
  FROM orders
  GROUP BY customerid
),

-- 2) Score R, F, M into quintiles (5 = best). Adjust NTILE if you want different granularity.
rfm_scores AS (
  SELECT
    customerid,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary,
    6 - NTILE(5) OVER (ORDER BY recency_days desc)   AS r_score,  -- lower recency_days => better
    NTILE(5) OVER (ORDER BY frequency DESC)          AS f_score,
    NTILE(5) OVER (ORDER BY monetary asc)           AS m_score
  FROM customer_rfm
),

-- 3) Composite RFM sum and assign 3 segments (High/Medium/Low)
rfm_segmented AS (
  SELECT
    customerid,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    (r_score + f_score + m_score) AS rfm_sum,
    NTILE(3) OVER (ORDER BY (r_score + f_score + m_score) DESC) AS tri_bucket
  FROM rfm_scores
),

-- 4) Label buckets: 1 -> High, 2 -> Medium, 3 -> Low
customer_segments AS (
  SELECT
    customerid,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary,
    r_score, f_score, m_score,
    rfm_sum,
    tri_bucket,
    CASE tri_bucket
      WHEN 1 THEN 'High'
      WHEN 2 THEN 'Medium'
      WHEN 3 THEN 'Low'
    END AS segment
  FROM rfm_segmented
)

-- A) Segment summary
SELECT
  segment,
  COUNT(*) AS customers,
  ROUND(AVG(monetary)::numeric,2) AS avg_monetary,
  ROUND(AVG(frequency)::numeric,2) AS avg_frequency,
  ROUND(AVG(recency_days)::numeric,2) AS avg_recency_days
FROM customer_segments
GROUP BY segment
ORDER BY CASE WHEN segment='High' THEN 1 WHEN segment='Medium' THEN 2 ELSE 3 END;



-- B) Top salesperson per segment (by revenue from customers in that segment)
-- Uncomment and run separately if you want this result:
,seg_sales AS (
  SELECT
    o.sales_person,
    cs.segment,
    SUM(o.sales_amount * COALESCE(o.quantity,1)) AS total_sales
  FROM orders o
  JOIN customer_segments cs ON o.customerid = cs.customerid
  GROUP BY o.sales_person, cs.segment
)
SELECT segment, sales_person, total_sales
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY segment ORDER BY total_sales DESC) AS rn
  FROM seg_sales
) t
WHERE rn = 1
ORDER BY CASE WHEN segment='High' THEN 1 WHEN segment='Medium' THEN 2 ELSE 3 END;



-- Checking whether comapny was able to reach it's target every month or not
-- % Target Achieved per State per Month.
SELECT
    o.stat,
    EXTRACT(YEAR FROM o.orderdate) AS year,
    EXTRACT(MONTH FROM o.orderdate) AS month,
    SUM(o.sales_amount) AS actual_sales,
    t.target AS target_sales,
    ROUND( (SUM(o.sales_amount) / t.target) * 100, 2 ) AS target_achieved_percent,
FROM orders o
JOIN salestarget t
    ON o.stat = t.state
    AND EXTRACT(YEAR FROM o.orderdate) = t.year
    AND EXTRACT(MONTH FROM o.orderdate) = t.month
GROUP BY o.stat, t.target, EXTRACT(YEAR FROM o.orderdate), EXTRACT(MONTH FROM o.orderdate)
ORDER BY year, month, stat;


--  How many targets were reached or achieved
WITH state_target_achievement AS (
    SELECT
        o.stat,
        o.region,
        EXTRACT(YEAR FROM o.orderdate) AS year,
        EXTRACT(MONTH FROM o.orderdate) AS month,
        SUM(o.sales_amount) AS actual_sales,
        t.target,
        ROUND((SUM(o.sales_amount) / t.target) * 100, 2) AS target_percent
    FROM orders o
    JOIN salestarget t
        ON o.stat = t.state
        AND EXTRACT(YEAR FROM o.orderdate) = t.year
        AND EXTRACT(MONTH FROM o.orderdate) = t.month
    GROUP BY o.stat, o.region, t.target, year, month,o.orderdate
),
state_failure_summary AS (
    SELECT
        stat,
        region,
        COUNT(*) FILTER (WHERE target_percent < 100) AS missed_months,
        COUNT(*) FILTER (WHERE target_percent >= 100) AS met_months,
        ROUND(AVG(target_percent), 2) AS avg_achievement
    FROM state_target_achievement
    GROUP BY stat, region
)
SELECT *
FROM state_failure_summary
WHERE missed_months >= 6   
ORDER BY avg_achievement;
