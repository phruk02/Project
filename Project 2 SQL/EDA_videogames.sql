--EDA (Exploratory Data Analysis)
-- 1.1. แพลตฟอร์มไหนมียอดขายรวมสูงสุด?
Select "Platform",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Platform"
ORDER BY Total_Sales DESC;


-- 1.2. Top 3 Platform ของแต่ละภูมิภาค

WITH region_sales AS (
  SELECT 'NA' AS region, "Platform", SUM("NA_Sales") AS sales
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'JP', "Platform", SUM("JP_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'EU', "Platform", SUM("EU_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'Other', "Platform", SUM("Other_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'Global', "Platform", SUM("Global_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
),
ranked AS (
  SELECT region, "Platform", sales,
         RANK() OVER(PARTITION BY region ORDER BY sales DESC) AS rk
  FROM region_sales
),
top3 AS (
  SELECT * FROM ranked WHERE rk <= 3
)
SELECT
  region,
  MAX(CASE WHEN rk = 1 THEN "Platform" END) AS rank1,
  MAX(CASE WHEN rk = 2 THEN "Platform" END) AS rank2,
  MAX(CASE WHEN rk = 3 THEN "Platform" END) AS rank3
FROM top3
GROUP BY region
ORDER BY region;
 
--1.3 Genre ที่ขายดีที่สุดของ platform PS2 ซึ่งเป็นplatform ขายดีที่สุด

Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
-- พบว่าแนว Sport และ Action มียอดขายใกล้เคียงกันจึงตัดสินใจดูทั้ง 2 Genre

-- 1.4.1 หา Publisher ที่ทำเงินจากเกม Genre ดังกล่าวมากที่สุด
WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

, Ac_SP AS (
SELECT "Publisher","Genre",SUM("Global_Sales") as total_sales 
From suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher","Genre"
), Ac_SP2 AS ( 
SELECT * 
FROM 
(SELECT *,SUM(total_sales) OVER(PARTITION BY "Publisher") as sum_2 
FROM Ac_SP)
ORDER BY sum_2 desc,total_sales desc
)
SELECT *
FROM Ac_SP2;

-- 1.4.2 หาเกมที่ขายดีจาก Publisher นั้น

WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

, Ac_SP AS (
SELECT "Publisher","Genre",SUM("Global_Sales") as total_sales 
From suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher","Genre"
), Ac_SP2 AS ( 
SELECT * 
FROM 
(SELECT *,SUM(total_sales) OVER(PARTITION BY "Publisher") as sum_2 
FROM Ac_SP)
ORDER BY sum_2 desc,total_sales desc
)

-----Code เดิมจาก1.4.1

, Ac_SP3 AS (
  SELECT *
  FROM suisuss.videogames_sales
  WHERE "Publisher" IN (
    SELECT "Publisher" FROM Ac_SP2 LIMIT 5
  )
    AND "Genre" IN ('Sports', 'Action')
    AND "Platform" = 'PS2'
),
ranked_games AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "Genre" ORDER BY "Global_Sales" DESC) AS rnk
  FROM Ac_SP3
)
SELECT "Name", "Genre", "Publisher", "Global_Sales"
FROM ranked_games
WHERE rnk = 1;

-- 1.4.3 หา Publisher ที่ทำเกม Genre ดังกล่าวออกมามากที่สุด
WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

SELECT "Publisher",COUNT(DISTINCT "Name") as total_games 
FROM suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher"
ORDER BY total_games DESC;


-- 2. ประเภทเกม (Genre) ไหนขายดีที่สุดทั่วโลก?

Select "Genre",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Genre"
ORDER BY Total_Sales DESC

--  3. ยอดขายเกมเปลี่ยนไปอย่างไรตามปี? (แนว Trend)

Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Year"
ORDER BY "Year";

--พบว่ายอดขายจะเพิ่มขึ้นเรื่อยๆและพีคในช่วง2007-2011 หลังจากนั้นจึงค่อยลดลง

--  3.1  Top 100 game with most sale between 2007-2011

Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Year" between 2007 and 2011
GROUP BY "Year"
ORDER BY "Year";

--  3.2  Top 100 game with most sale between 2007-2011

SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100;

--  3.3  หาที่Publisher ขายดีที่สุดในช่วง 2007-2011

SELECT  "Platform", SUM("Global_Sales") as Total_Sales FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
GROUP BY "Platform"
ORDER BY Total_Sales DESC
LIMIT 100;

SELECT  "Publisher", SUM("Global_Sales") as Total_Sales FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
GROUP BY "Publisher"
ORDER BY Total_Sales DESC
LIMIT 100;



-- 3.3 เกมใน Top 100 เหล่านี้ เคยขายดีใน Region ไหนมากที่สุด
WITH TopGame07_11 AS(
SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100
)
, TopGame07_11_GR AS( 
SELECT  "Publisher","Platform", COUNT("Name") as name_count 
FROM TopGame07_11
GROUP BY "Publisher","Platform"
ORDER BY  "Publisher" 
)

-- 3.4 Top 100 เหล่านี้ ส่วนใหญ่มาจาก Publisher เจ้าใด?


-- 3.5  Platform ใดใน Top 100 ที่มี "แนวเกมเฉพาะทาง" มากที่สุด?