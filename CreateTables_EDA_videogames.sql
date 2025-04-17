-- 1.1. แพลตฟอร์มไหนมียอดขายรวมสูงสุด?
CREATE TABLE IF NOT EXISTS suisuss.mostsales_by_plat_1 AS
Select "Platform",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Platform"
ORDER BY Total_Sales DESC;



-- 1.2. Top 3 Platform ของแต่ละภูมิภาค
CREATE TABLE IF NOT EXISTS suisuss.T3_plat_2 AS
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
CREATE TABLE IF NOT EXISTS suisuss.bestgamePS2_3 AS
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC;
-- พบว่าแนว Sport และ Action มียอดขายใกล้เคียงกันจึงตัดสินใจดูทั้ง 2 Genre

-- 1.4.1 หา Publisher ที่ทำเงินจากเกม Genre ดังกล่าวมากที่สุด
CREATE TABLE IF NOT EXISTS suisuss.PS2bestPublisher_4_1 AS
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
CREATE TABLE   suisuss.PS2bestGame_4_2 AS
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
CREATE TABLE suisuss.AcSp_Publisher_4_3 AS
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
CREATE TABLE suisuss.Sales_By_Genre_2_0 AS
Select "Genre",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Genre"
ORDER BY Total_Sales DESC;

--  3. ยอดขายเกมเปลี่ยนไปอย่างไรตามปี? (แนว Trend)
CREATE TABLE suisuss.Sales_By_Year_3_0 AS
Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Year"
ORDER BY "Year";

--  3.1 Top 100 game with most sale between 2007-2011
CREATE TABLE suisuss.Sales_By_Year_3_1 AS
Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Year" between 2007 and 2011
GROUP BY "Year"
ORDER BY "Year";

CREATE TABLE suisuss.Topgame07_11_3_2 AS
SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100;



